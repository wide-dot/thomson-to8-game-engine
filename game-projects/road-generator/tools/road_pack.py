#!/usr/bin/env python3
"""
road_pack.py — ÉTAPE A : packer pages 16 Ko + index + keyframe table -> binaires builder.

Produit, par circuit, à partir du flux de records DIFF/KEYFRAME (cf. road_diff_proto) :
  - <circuit>_pages.bin  : toutes les pages de 16384 o concaténées (paddées), à poser
                           sur des pages cart CONSÉCUTIVES (mount via _SetCartPageA).
  - <circuit>_index.bin  : header + index résident frame -> (page:1, addr:2) big-endian.
                           addr = OFFSET dans la page (0..16383) ; le runtime ajoute la
                           base de la fenêtre cart mountée.

Records (1er octet = type) — IDENTIQUE à road_diff_proto / doc 42 §2 :
  $00..$60 = DIFF      : n(1) min_y(1) [ Y(1) f(2) w(2) e(2) ] × n        (n = nb lignes changées)
  $FE      = KEYFRAME  : $FE min_y(1) [ f(2) w(2) e(2) ] × (96-min_y)
  $FF      = NEXT-PAGE : aucun payload -> mount page+1, ptr = base de page, relire.
On ne COUPE JAMAIS un record en travers d'une page : s'il ne tient pas avant
(page_size - 1), on pose $FF et on passe à la page suivante. (= pattern PlayDPCM16kHz.)

⚠️ SÉCURITÉ : le packer s'auto-valide LOSSLESS en simulant le décodeur forward runtime
(suivi de pointeur + $FF) et en comparant la reconstruction à l'original byte-exact.
Toute divergence => AssertionError (rien n'est écrit).

Usage :
  .venv/bin/python3 tools/road_pack.py --circuit 22_hard_5 --S 2 --KF 64 --out baked/
  .venv/bin/python3 tools/road_pack.py --all --S 2 --info
  .venv/bin/python3 tools/road_pack.py --illustrate          # exemple lisible + frontière de page
"""
import sys, argparse, struct
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import road_bake as rb
import road_diff_proto as dp

PAGE_SIZE = 16384       # taille d'une page cart
NEXT_PAGE = 0xFF        # marqueur changement de page
KEYFRAME  = 0xFE        # marqueur keyframe


# ── 1. Flux de records (KEYFRAME tous les KF, DIFF sinon) ────────────────────
def record_stream(frames, KF):
    """Génère (frame_idx, record_bytes, is_keyframe).
    L'état est RESET à chaque keyframe (le décodeur recopie la frame complète),
    et les diffs suivants sont calculés relativement à cet état reset -> le
    décodeur forward reproduit exactement la même séquence."""
    state, state_my = {}, 96
    for i, fr in enumerate(frames):
        if i % KF == 0:
            rec = dp.rec_keyframe(fr)
            state = {y: fr[1].get(y, (0, 0, 0)) for y in range(fr[0], 96)}
            state_my = fr[0]
            yield i, rec, True
        else:
            cur_my, ch = dp.diff_changes(state_my, state, fr)
            rec = dp.rec_diff(cur_my, ch)
            for y, cv in ch:
                state[y] = cv
            state_my = cur_my
            yield i, rec, False


# ── 1bis. Frames à partir de segments ÉDITÉS (bypass parse_circuit) ───────────
# segs = liste de [delta_curve, delta_pitch, pit, start] (= format road_bake.project_pos).
def frames_from_segs(segs, nb, S, assets):
    out = []
    for p in range(0, nb * rb.SUBPOS_PER_SEG, S):
        dense, min_y = rb.project_pos(segs, nb, p, assets)
        row = {y: (dense[y]['flags'] & 0xFFFF, dense[y]['width'] & 0xFFFF,
                   dense[y].get('extra', 0) & 0xFFFF) for y in dense}
        out.append((min_y, row))
    return out


# ── 2. Packing en pages 16 Ko (+ index + keyframe table) ─────────────────────
def pack_frames(frames, KF, page_size=PAGE_SIZE):
    pages = [bytearray()]
    index = []                      # par frame : (page, offset)
    kf_table = []                   # par keyframe : (frame, page, offset)
    for i, rec, is_kf in record_stream(frames, KF):
        cur = pages[-1]
        if len(cur) + len(rec) > page_size - 1:   # jamais couper un record (réserve $FF)
            cur.append(NEXT_PAGE)
            pages.append(bytearray())
            cur = pages[-1]
        index.append((len(pages) - 1, len(cur)))
        if is_kf:
            kf_table.append((i, len(pages) - 1, len(cur)))
        cur += rec
    for p in pages:                                # padder à 16 Ko (page cart fixe)
        if len(p) < page_size:
            p += b'\x00' * (page_size - len(p))
    return pages, index, kf_table


def pack_circuit(circuit, S, KF, assets, page_size=PAGE_SIZE):
    frames = dp.frames_of(circuit, S, assets)
    pages, index, kf_table = pack_frames(frames, KF, page_size)
    return frames, pages, index, kf_table


def pack_from_segs(segs, nb, S, KF, assets, page_size=PAGE_SIZE):
    frames = frames_from_segs(segs, nb, S, assets)
    pages, index, kf_table = pack_frames(frames, KF, page_size)
    return frames, pages, index, kf_table


# ── 3. Décodeur forward SIMULÉ (= ce que fera l'ASM) -> validation lossless ──
def decode_forward(pages, index, N, page_size=PAGE_SIZE):
    """Suit le pointeur depuis la frame 0 en appliquant les records, comme le
    runtime. Retourne la liste des frames reconstruites (full_lines par Y)."""
    state, state_my = {}, 96
    page, ptr = 0, 0
    recon = []
    for i in range(N):
        # franchir les $FF
        while pages[page][ptr] == NEXT_PAGE:
            page += 1
            ptr = 0
        # le pointeur DOIT coïncider avec l'index (cohérence forward/seek)
        if index[i] != (page, ptr):
            raise AssertionError(f"frame {i}: pointeur {(page, ptr)} != index {index[i]}")
        b = pages[page][ptr]
        if b == KEYFRAME:
            my = pages[page][ptr + 1]
            off = ptr + 2
            state = {}
            for y in range(my, 96):
                f, w, e = struct.unpack('>HHH', bytes(pages[page][off:off + 6]))
                state[y] = (f, w, e)
                off += 6
            state_my = my
            ptr = off
        else:
            n = b
            my = pages[page][ptr + 1]
            off = ptr + 2
            for _ in range(n):
                y = pages[page][off]
                f, w, e = struct.unpack('>HHH', bytes(pages[page][off + 1:off + 7]))
                state[y] = (f, w, e)
                off += 7
            state_my = my
            ptr = off
        recon.append({y: state.get(y, (0, 0, 0)) for y in range(state_my, 96)})
    return recon


def validate(frames, pages, index, page_size=PAGE_SIZE):
    recon = decode_forward(pages, index, len(frames), page_size)
    for i, fr in enumerate(frames):
        if recon[i] != dp.full_lines(fr):
            raise AssertionError(f"pos#{i}: reconstruction forward != original (PACKER CASSÉ)")
    return True


# ── 4. Écriture binaire (pages + index résident) ────────────────────────────
def write_circuit(circuit, S, KF, outdir, assets, page_size=PAGE_SIZE):
    frames, pages, index, kf_table = pack_circuit(circuit, S, KF, assets, page_size)
    validate(frames, pages, index, page_size)          # GATE : rien d'écrit si cassé
    outdir = Path(outdir)
    outdir.mkdir(parents=True, exist_ok=True)

    # pages : blob continu
    blob = b''.join(bytes(p) for p in pages)
    (outdir / f'{circuit}_pages.bin').write_bytes(blob)

    # index résident : header(8) + [page(1) addr_hi(1) addr_lo(1)] × N
    #   header : N(2) S(2) KF(2) nb_pages(2)  (big-endian)
    N = len(index)
    header = struct.pack('>HHHH', N, S, KF, len(pages))
    idx = bytearray()
    for pg, ad in index:
        idx += bytes([pg & 0xFF, (ad >> 8) & 0xFF, ad & 0xFF])
    (outdir / f'{circuit}_index.bin').write_bytes(header + bytes(idx))

    return stats(circuit, S, KF, frames, pages, index, kf_table)


# ── 4bis. Émission des fichiers de BUILD (chunks ≤16Ko + wrappers + index ASM) ──
# Vérifié source Java : aucun objet ne peut dépasser PAGE_SIZE ($4000), et le build
# n'étale PAS un binaire sur plusieurs pages. On émet donc 1 objet code-only PAR page
# logique (chunk), paddé à EXACTEMENT 16384 -> occupe toute sa page -> base $0000 garantie.
# Au runtime : chunk k -> page physique = Obj_Index_Page + ObjID_RoadStreamP0 + k.
# base_path = dossier engine-relatif où les fichiers stream VIVRONT (inscrit en dur
# dans les INCLUDEBIN / code= / object= générés). Défaut = layout historique partagé.
DEFAULT_BASE = './objects/road-stream-data'


def emit_build(circuit, S, KF, outdir, assets, prefix='RoadStreamP', base_path=DEFAULT_BASE):
    frames, pages, index, kf_table = pack_circuit(circuit, S, KF, assets)
    return _emit_files(frames, pages, index, kf_table, S, KF, outdir, circuit, prefix, base_path)


def emit_build_from_segs(segs, nb, S, KF, outdir, assets, circuit='circuit', prefix='RoadStreamP', base_path=DEFAULT_BASE):
    """Comme emit_build mais à partir des segments ÉDITÉS (pas d'un .asm disque)."""
    frames, pages, index, kf_table = pack_from_segs(segs, nb, S, KF, assets)
    return _emit_files(frames, pages, index, kf_table, S, KF, outdir, circuit, prefix, base_path)


def _emit_files(frames, pages, index, kf_table, S, KF, outdir, circuit, prefix='RoadStreamP', base_path=DEFAULT_BASE):
    base = base_path.rstrip('/')
    validate(frames, pages, index)
    outdir = Path(outdir)
    outdir.mkdir(parents=True, exist_ok=True)
    bdir = outdir / 'generated'
    bdir.mkdir(parents=True, exist_ok=True)
    nchunks = len(pages)

    # 1) chunks .bin (paddés à 16384) + wrapper .asm + obj.properties par chunk
    for k, p in enumerate(pages):
        assert len(p) == PAGE_SIZE, f"chunk {k} = {len(p)} != {PAGE_SIZE}"
        (bdir / f'{circuit}_chunk_{k:02d}.bin').write_bytes(bytes(p))
        wrapper = (
            f"* road-stream data — chunk {k}/{nchunks-1} du circuit {circuit}\n"
            f"* Pure data (DIFF/KEYFRAME packés). ORG $0000 -> base de page garantie\n"
            f"* (paddé à 16384 = occupe toute la page). Lu via Obj_Index_Page+ObjID_{prefix}{k}.\n"
            f"        ORG   $0000\n"
            f'        INCLUDEBIN "{base}/generated/{circuit}_chunk_{k:02d}.bin"\n'
        )
        (outdir / f'chunk_{k:02d}.asm').write_text(wrapper)
        (outdir / f'chunk_{k:02d}.properties').write_text(
            f"# road-stream chunk {k} ({circuit}) — objet data-only, 1 page cart pleine.\n"
            f"code={base}/chunk_{k:02d}.asm\n")

    # 2) index résident en ASM : N entrées [fcb chunk] [fdb addr]
    L = [
        f"* road-stream INDEX résident — circuit {circuit} (S={S}, KF={KF})",
        f"* {len(index)} frames. Par frame : fcb chunk ; fdb addr (offset dans page, base $0000).",
        f"* chunk -> page physique au runtime : Obj_Index_Page + ObjID_{prefix}0 + chunk.",
        f"RoadStream_NbFrames   equ {len(index)}",
        f"RoadStream_S          equ {S}",
        f"RoadStream_KF         equ {KF}",
        f"RoadStream_NbChunks   equ {nchunks}",
        f"RoadStream_Index",
    ]
    for pg, ad in index:
        L.append(f"        fcb   {pg:<3d}            ; chunk")
        L.append(f"        fdb   ${ad:04X}          ; addr")
    (outdir / f'{circuit}_index.asm').write_text("\n".join(L) + "\n")

    # 3) snippet des déclarations object.X à coller dans le main.properties du game-mode
    snip = ["# --- road-stream data : 1 objet code-only par page logique (chunk) ---",
            "# ⚠️ déclarer dans CET ORDRE pour que les ObjID soient consécutifs",
            f"#     (chunk k -> page via Obj_Index_Page + ObjID_{prefix}0 + k)."]
    for k in range(nchunks):
        snip.append(f"object.{prefix}{k}={base}/chunk_{k:02d}.properties")
    (outdir / 'OBJECTS_SNIPPET.properties.txt').write_text("\n".join(snip) + "\n")

    return {'circuit': circuit, 'nchunks': nchunks, 'N': len(index),
            'index_bytes': 3 * len(index), 'pages_bytes': nchunks * PAGE_SIZE,
            'outdir': str(outdir)}


def stats(circuit, S, KF, frames, pages, index, kf_table):
    N = len(frames)
    rec_bytes = sum(96 - f[0] for f in frames)        # indicatif
    used = sum(len(bytes(p).rstrip(b'\x00')) for p in pages)  # approx (peut sous-estimer si data finit par 0)
    return {
        'circuit': circuit, 'S': S, 'KF': KF, 'N': N,
        'pages': len(pages), 'pages_bytes': len(pages) * PAGE_SIZE,
        'index_bytes': 8 + N * 3, 'n_kf': len(kf_table),
        'avg_lines': sum(96 - f[0] for f in frames) / N,
    }


# ── 5. Illustration lisible (frontière de page incluse) ──────────────────────
def illustrate(circuit, S, KF, assets, start=None, count=8, page_size=512):
    frames = dp.frames_of(circuit, S, assets)
    # si start non fourni : trouver une région en courbe (DIFF non trivial) pour l'exemple
    if start is None:
        start = 0
        st, smy = {}, 96
        for i, fr in enumerate(frames):
            cur_my, ch = dp.diff_changes(smy, st, fr)
            for y, cv in ch:
                st[y] = cv
            smy = cur_my
            if i > 0 and 0 < len(ch) <= 10:
                start = max(0, i - 1)
                break
    sub = frames[start:start + count]
    # re-générer le flux sur le sous-ensemble en repartant d'une keyframe
    state, state_my = {}, 96
    page, ptr = 0, 0
    print(f"=== ILLUSTRATION — {circuit}, frames {start}..{start+count-1}")
    print(f"    page_size={page_size}o (réel=16384) ; records packés, $FF = NEXT-PAGE\n")
    for j, fr in enumerate(sub):
        i = start + j
        if j == 0 or (i % KF == 0):
            rec = dp.rec_keyframe(fr); kind = "KEYFRAME"
            state = {y: fr[1].get(y, (0, 0, 0)) for y in range(fr[0], 96)}; state_my = fr[0]
        else:
            cur_my, ch = dp.diff_changes(state_my, state, fr)
            rec = dp.rec_diff(cur_my, ch); kind = f"DIFF ({len(ch)} lignes)"
            for y, cv in ch:
                state[y] = cv
            state_my = cur_my
        if ptr + len(rec) > page_size - 1:
            print(f"  [pg{page} @{ptr:3d}]  FF                                  ; NEXT-PAGE")
            page += 1; ptr = 0
        print(f"  [pg{page} @{ptr:3d}]  {dp.hexs(rec, 12):<40s} ; frame {i} {kind} {len(rec)}o "
              f"-> index(pg{page},@{ptr})")
        ptr += len(rec)


def kb(b): return f"{b/1024:.1f}Ko"


def main(argv):
    ap = argparse.ArgumentParser()
    ap.add_argument('--circuit')
    ap.add_argument('--all', action='store_true')
    ap.add_argument('--S', type=int, default=2)
    ap.add_argument('--KF', type=int, default=64)
    ap.add_argument('--out', default='baked')
    ap.add_argument('--info', action='store_true', help='tailles seulement (pas d\'écriture)')
    ap.add_argument('--illustrate', action='store_true')
    ap.add_argument('--emit-build', action='store_true',
                    help='émet chunks paddés + wrappers asm + obj.properties + index asm pour le game-mode')
    a = ap.parse_args(argv)
    assets = rb.load_assets()

    if a.illustrate:
        illustrate(a.circuit or '22_hard_5', a.S, a.KF, assets)
        return

    if a.emit_build:
        cid = a.circuit or '22_hard_5'
        out = a.out if a.out != 'baked' else 'objects/road-stream-data'
        st = emit_build(cid, a.S, a.KF, out, assets)
        print(f"\n=== EMIT BUILD {cid} (S={a.S}, KF={a.KF}) — validé lossless forward ===")
        print(f"  {st['nchunks']} chunks × 16Ko = {kb(st['pages_bytes'])} (pages cart)")
        print(f"  index résident : {st['N']} frames × 3 o = {kb(st['index_bytes'])}")
        print(f"→ {st['outdir']}/  : chunk_NN.{{bin(generated/),asm,properties}}, {cid}_index.asm, OBJECTS_SNIPPET.properties.txt")
        return

    circuits = rb.list_circuits() if a.all else [a.circuit or '22_hard_5']
    print(f"\n=== PACK pages {PAGE_SIZE//1024}Ko (S={a.S}, keyframe/{a.KF}) — validé lossless forward ===")
    print(f"{'circuit':14s}{'pos':>6s}{'lignes':>7s}{'pages':>6s}{'pages_o':>9s}{'index':>8s}{'kf':>5s}")
    tot_pg = tot_idx = 0
    for c in circuits:
        if a.info:
            frames, pages, index, kf_table = pack_circuit(c, a.S, a.KF, assets)
            validate(frames, pages, index)
            st = stats(c, a.S, a.KF, frames, pages, index, kf_table)
        else:
            st = write_circuit(c, a.S, a.KF, a.out, assets)
        tot_pg += st['pages_bytes']; tot_idx += st['index_bytes']
        print(f"{c:14s}{st['N']:>6d}{st['avg_lines']:>7.0f}{st['pages']:>6d}"
              f"{kb(st['pages_bytes']):>9s}{kb(st['index_bytes']):>8s}{st['n_kf']:>5d}")
    if len(circuits) > 1:
        print(f"{'TOTAL':14s}{'':>6s}{'':>7s}{'':>6s}{kb(tot_pg):>9s}{kb(tot_idx):>8s}")
    print("\n✓ chaque circuit re-décodé en forward (suivi pointeur + $FF) == original byte-exact.")
    if not a.info and not a.illustrate:
        print(f"→ écrit dans {a.out}/  (<circuit>_pages.bin = pages cart ; <circuit>_index.bin = résident)")


if __name__ == '__main__':
    main(sys.argv[1:])
