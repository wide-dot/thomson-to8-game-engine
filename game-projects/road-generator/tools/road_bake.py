#!/usr/bin/env python3
"""
road_bake.py — SOURCE UNIQUE : projection + rendu + bake des données piste→binaire.

Principe : on NE ré-implémente RIEN. On réutilise le pipeline byte-perfect déjà
validé contre l'émulateur (simulate_dfr_pipeline.py = SP+LI, render_road_frame.py
= rendu texturé réel). Le preview Tkinter (road_preview_tk.py) appelle les MÊMES
fonctions project()/render() → ce que tu prévisualises est EXACTEMENT ce qui est
baké. Aucune divergence possible.

CLI :
  road_bake.py --circuit 22_hard_5 --S 4 --out baked/     # 1 circuit
  road_bake.py --all --S 4 --out baked/                    # tous les circuits
  road_bake.py --info --S 4                                # tailles seulement (tous)

Format binaire baké (par circuit, "table complète + offset ligne de départ") :
  positions échantillonnées tous les /S (S sous-positions ; 16 sous-pos/segment).
  Par position : [min_y:1] [ (flags:2, width:2, extra:2) × (96 - min_y) ]  (big-endian)
  + une table d'index (offset uint32 de chaque position dans le blob) pour le
  random-access runtime. ZX0 = étape de compression séparée (post-traitement).
"""
import sys, struct, argparse, re
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from simulate_dfr_pipeline import (
    parse_circuit, load_perspective_tables, sparse_projection,
    linear_interp, load_persp_recip_paged,
)

ROOT = Path(__file__).resolve().parent.parent
SUBPOS_PER_SEG = 16   # nibble 0..15


# ── Assets (chargés une fois) ───────────────────────────────────────────────
def load_assets(root=ROOT):
    hor, scal = load_perspective_tables(root / 'lotus-ste/doc/extraction/unpacked/FILE59.bin')
    paged = load_persp_recip_paged(root / 'engine/projection/Persp_Recip_paged.bin')
    return {'horizon': hor, 'scaling': scal, 'paged': paged}


def circuit_nb_segments(circuit_id, root=ROOT):
    """Vraie longueur du circuit (sans les 8 segments dupliqués de lookahead)."""
    asm = (root / 'engine/circuits' / f'{circuit_id}.asm').read_text()
    m = re.search(rf'Circuit_{circuit_id}_nb_segments\s*\n?\s*fdb\s+(\d+)', asm)
    if m:
        return int(m.group(1))
    m = re.search(rf'Circuit_{circuit_id}_nb_segments\s+fdb\s+(\d+)', asm)
    return int(m.group(1)) if m else None


def list_circuits(root=ROOT):
    return sorted(p.stem for p in (root / 'engine/circuits').glob('*.asm'))


# ── Projection (= SP+LI byte-perfect) ───────────────────────────────────────
def project(segments, seg, nibble, assets):
    """seg, nibble -> (dense {Y:{flags,width,extra}}, min_y). Réutilise le pipeline."""
    slots, min_y = sparse_projection(segments, seg, nibble, assets['horizon'], assets['scaling'])
    dense = linear_interp(slots, assets['paged'])
    return dense, min_y


def project_pos(segments, nb_seg, pos, assets):
    """pos = sous-position globale 0..(nb_seg*16-1)."""
    pos %= nb_seg * SUBPOS_PER_SEG
    return project(segments, pos // SUBPOS_PER_SEG, pos % SUBPOS_PER_SEG, assets)


# ── Rendu texturé RÉEL (= render_ref_real, vraies lignes normal_dark/light) ──
def render(dense, steer, phase=0, root=ROOT):
    """dense -> PIL Image 160×96 (vraies textures). steer = lateral_pos (±192).
    phase = (track_pos.lower>>4)&$7FF : fait défiler les bandes dark/light (live)."""
    from render_road_frame import render_ref_real, _signed16
    return render_ref_real(dense, _signed16(steer * 8), 0, 96, root, phase)


# ── Bake binaire ────────────────────────────────────────────────────────────
def bake_position(dense, min_y):
    """1 position -> bytes : [min_y][ (flags,width,extra) × (96-min_y) ]."""
    out = bytearray([min_y & 0xFF])
    for y in range(min_y, 96):
        t = dense.get(y)
        if t:
            out += struct.pack('>HHH', t['flags'] & 0xFFFF, t['width'] & 0xFFFF, t.get('extra', 0) & 0xFFFF)
        else:
            out += b'\x00\x00\x00\x00\x00\x00'
    return bytes(out)


def bake_circuit(circuit_id, S, assets, root=ROOT):
    """Retourne (blob, index, stats). index = liste d'offsets uint32 dans blob."""
    segments = parse_circuit(root / 'engine/circuits' / f'{circuit_id}.asm', circuit_id)
    nb_seg = circuit_nb_segments(circuit_id, root)
    npos = nb_seg * SUBPOS_PER_SEG
    blob = bytearray()
    index = []
    nlines = []
    for pos in range(0, npos, S):
        dense, min_y = project_pos(segments, nb_seg, pos, assets)
        index.append(len(blob))
        blob += bake_position(dense, min_y)
        nlines.append(96 - min_y)
    stats = {
        'circuit': circuit_id, 'nb_seg': nb_seg, 'S': S,
        'positions': len(index), 'blob_bytes': len(blob),
        'index_bytes': len(index) * 4,
        'total_bytes': len(blob) + len(index) * 4,
        'avg_lines': sum(nlines) / len(nlines) if nlines else 0,
        'min_lines': min(nlines) if nlines else 0,
        'max_lines': max(nlines) if nlines else 0,
    }
    return bytes(blob), index, stats


def write_baked(circuit_id, S, outdir, assets, root=ROOT):
    blob, index, st = bake_circuit(circuit_id, S, assets, root)
    outdir = Path(outdir); outdir.mkdir(parents=True, exist_ok=True)
    # fichier = header(8) + index(uint32×N) + blob
    header = struct.pack('>HHHH', st['positions'], S, st['nb_seg'], 96)
    idx = b''.join(struct.pack('>I', o) for o in index)
    (outdir / f'{circuit_id}_S{S}.bin').write_bytes(header + idx + blob)
    return st


def dump_asm(circuit_id, start, count, assets, out, root=ROOT):
    """Dump `count` frames consécutives (à partir de `start`) en ASM lisible,
    annoté pour repérer les axes d'optimisation (flags nuls = droite ; width/extra
    identiques à la frame précédente = redondance compressible)."""
    segments = parse_circuit(root / 'engine/circuits' / f'{circuit_id}.asm', circuit_id)
    nb_seg = circuit_nb_segments(circuit_id, root)
    npos = nb_seg * SUBPOS_PER_SEG
    L = []
    L.append("; ============================================================================")
    L.append(f"; road_bake — dump ASM circuit {circuit_id}  (frames {start}..{start+count-1})")
    L.append("; Une frame = 1 sous-position. Format : fcb min_y ; puis par scanline")
    L.append(";   fdb flags,width,extra  (flags=courbe|drapeaux, width=largeur, extra=teinte).")
    L.append(";   Annotations : 'DROITE' = flags nuls ; '= prec' = colonne identique à la")
    L.append(";   frame precedente (= redondance -> compressible / partageable).")
    L.append("; ============================================================================")
    pw = pe = pf = None
    for i in range(count):
        pos = (start + i) % npos
        seg, nib = pos // SUBPOS_PER_SEG, pos % SUBPOS_PER_SEG
        dense, min_y = project_pos(segments, nb_seg, pos, assets)
        ys = list(range(min_y, 96))
        fl = [(dense[y]['flags'] & 0xFFFF) if dense.get(y) else 0 for y in ys]
        wd = [(dense[y]['width'] & 0xFFFF) if dense.get(y) else 0 for y in ys]
        ex = [(dense[y].get('extra', 0) & 0xFFFF) if dense.get(y) else 0 for y in ys]
        nzf = sum(1 for f in fl if f & 0xFFFC)         # flags hors bits drapeaux PIT/START
        fsame, wsame, esame = (fl == pf), (wd == pw), (ex == pe)
        L.append("")
        L.append(f"; ---- pos {pos} (seg {seg} nib {nib})  min_y={min_y}  lignes={len(ys)} ----")
        L.append(f";   flags : {'DROITE (tous nuls)' if nzf == 0 else f'{nzf} non-nuls (courbe)'}"
                 f"{'  [= prec]' if fsame else ''}")
        L.append(f";   width : {'= prec (REDONDANT)' if wsame else 'change'}"
                 f"      extra : {'= prec (REDONDANT)' if esame else 'change'}")
        L.append(f"frame_s{seg:03d}_n{nib:02d}:")
        L.append(f"        fcb   {min_y:<3d}                       ; min_y (offset depart)")
        for y, f, w, e in zip(ys, fl, wd, ex):
            L.append(f"        fdb   ${f:04X},${w:04X},${e:04X}        ; Y={y:<2d} w={w >> 8:>3d}")
        pf, pw, pe = fl, wd, ex
    Path(out).write_text("\n".join(L) + "\n")
    return len(L), out


def fmt_kb(b): return f"{b/1024:.1f} Ko"


def main(argv):
    ap = argparse.ArgumentParser()
    ap.add_argument('--circuit')
    ap.add_argument('--all', action='store_true')
    ap.add_argument('--S', type=int, default=4)
    ap.add_argument('--out', default='baked')
    ap.add_argument('--info', action='store_true', help='tailles seulement, pas d\'écriture')
    ap.add_argument('--asm', action='store_true', help='dump ASM lisible de frames (inspection)')
    ap.add_argument('--from', dest='start', type=int, default=0, help='1ère frame (--asm)')
    ap.add_argument('--count', type=int, default=16, help='nb de frames (--asm, def 16 = 1 segment)')
    a = ap.parse_args(argv)

    assets = load_assets()

    if a.asm:
        cid = a.circuit or '22_hard_5'
        out = a.out if a.out != 'baked' else f'{cid}_frames.asm'
        n, path = dump_asm(cid, a.start, a.count, assets, out)
        print(f"→ {a.count} frames (pos {a.start}..{a.start+a.count-1}) dumpées dans {path} ({n} lignes ASM)")
        return
    circuits = list_circuits() if a.all else [a.circuit]
    if not circuits or circuits == [None]:
        print("Précise --circuit <id> ou --all"); return

    tot = 0
    print(f"{'circuit':16s} {'seg':>4s} {'pos':>5s} {'lignes(moy/max)':>16s} {'blob':>9s} {'idx':>8s} {'total':>9s} {'ZX0~÷3':>9s}")
    for cid in circuits:
        try:
            if a.info:
                _, _, st = bake_circuit(cid, a.S, assets)
            else:
                st = write_baked(cid, a.S, a.out, assets)
        except Exception as e:
            print(f"{cid:16s} ERREUR: {e}"); continue
        tot += st['total_bytes']
        print(f"{cid:16s} {st['nb_seg']:>4d} {st['positions']:>5d} "
              f"{st['avg_lines']:>6.0f}/{st['max_lines']:<3d}        "
              f"{fmt_kb(st['blob_bytes']):>9s} {fmt_kb(st['index_bytes']):>8s} "
              f"{fmt_kb(st['total_bytes']):>9s} {fmt_kb(st['total_bytes']/3):>9s}")
    print(f"{'TOTAL':16s} {'':>4s} {'':>5s} {'':>16s} {'':>9s} {'':>8s} {fmt_kb(tot):>9s} {fmt_kb(tot/3):>9s}")
    if not a.info:
        print(f"→ écrit dans {a.out}/")


if __name__ == '__main__':
    main(sys.argv[1:])
