#!/usr/bin/env python3
"""
road_diff_proto.py — Prototype du format DIFF-forward (+ keyframes).

Idée : la voiture n'avance que vers l'avant. On stocke, pour chaque sous-position,
le DIFF par rapport à la précédente (= les seules scanlines qui changent). Au
runtime on maintient le Dense_Buffer résident et on applique le diff (souvent rien).
Des keyframes périodiques (frame complète) permettent le seek/respawn.

Ce proto :
  1. encode le flux de diffs + table de keyframes,
  2. VALIDE que reconstruire = l'original (lossless, byte-exact),
  3. chiffre TAILLE (octets) et COÛT (cycles 6809 modélisés) par avance.

Réutilise road_bake (project) — même source de vérité.

Format flux diff, par sous-position (sauf la 1ère = via keyframe) :
  [n_changes:1] [min_y:1] [ (Y:1, flags:2, width:2, extra:2) × n_changes ]   (big-endian)
Keyframe (table seek, tous les KF) :
  [min_y:1] [ (flags:2, width:2, extra:2) × (96-min_y) ]

Décodeur runtime (modèle) :
  appliquer diff : lire n, lire min_y -> Proj_min_y ; n× { lire Y ; Dense+Y*6 ; ecrire 6o }

Usage : .venv/bin/python3 tools/road_diff_proto.py [--circuit X | --all] [--S 1] [--KF 64]
"""
import sys, argparse, struct
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import road_bake as rb
from simulate_dfr_pipeline import parse_circuit

SUB = 16

# ── modèle de coût 6809 (cycles) — approx, à affiner sur l'ASM réel ──
CYC_DIFF_FIXED = 18         # lire n_changes + min_y + store Proj_min_y
CYC_PER_CHANGE = 60         # lire Y + Y*6 (mul) + copier 6 octets vers Dense
CYC_KF_PER_BYTE = 4         # blit keyframe -> Dense


def frames_of(circuit, S, assets):
    segs = parse_circuit(rb.ROOT / 'engine/circuits' / f'{circuit}.asm', circuit)
    nb = rb.circuit_nb_segments(circuit)
    npos = nb * SUB
    out = []
    for p in range(0, npos, S):
        dense, min_y = rb.project_pos(segs, nb, p, assets)
        row = {y: (dense[y]['flags'] & 0xFFFF, dense[y]['width'] & 0xFFFF,
                   dense[y].get('extra', 0) & 0xFFFF) for y in dense}
        out.append((min_y, row))
    return out


def full_lines(frame):
    """dict Y->triplet pour Y dans [min_y..95] (les lignes dessinées)."""
    my, row = frame
    return {y: row.get(y, (0, 0, 0)) for y in range(my, 96)}


def diff_changes(prev_my, prev_state, cur):
    """Liste des Y à (ré)écrire pour passer de l'état courant à la frame cur.
    Inclut : lignes qui apparaissent (Y < prev_my) + lignes dont le triplet change."""
    cur_my, cur_row = cur
    changes = []
    for y in range(cur_my, 96):
        cv = cur_row.get(y, (0, 0, 0))
        if y < prev_my or prev_state.get(y) != cv:
            changes.append((y, cv))
    return cur_my, changes


def encode_diff(cur_my, changes):
    b = bytearray([len(changes) & 0xFF, cur_my & 0xFF])
    for y, (f, w, e) in changes:
        b += bytes([y]) + struct.pack('>HHH', f, w, e)
    return bytes(b)


def encode_keyframe(frame):
    my, row = frame
    b = bytearray([my & 0xFF])
    for y in range(my, 96):
        f, w, e = row.get(y, (0, 0, 0))
        b += struct.pack('>HHH', f, w, e)
    return bytes(b)


def build(circuit, S, KF, assets):
    frames = frames_of(circuit, S, assets)
    N = len(frames)

    diff_stream = bytearray()
    diff_sizes = []
    change_counts = []
    keyframes = bytearray()
    n_keyframes = 0

    # état "résident" simulé pour produire les diffs + valider
    state = {}      # Y -> triplet
    state_my = 96
    for i, fr in enumerate(frames):
        # keyframe table (seek)
        if i % KF == 0:
            keyframes += encode_keyframe(fr)
            n_keyframes += 1
        # diff depuis l'état courant
        cur_my, changes = diff_changes(state_my, state, fr)
        diff_stream += encode_diff(cur_my, changes)
        diff_sizes.append(2 + 7 * len(changes))
        change_counts.append(len(changes))
        # appliquer (= ce que fera le runtime) pour avancer l'état
        for y, cv in changes:
            state[y] = cv
        state_my = cur_my
        # VALIDATION lossless : l'état dessiné == la frame originale ?
        drawn = {y: state[y] for y in range(state_my, 96)}
        if drawn != full_lines(fr):
            raise AssertionError(f"{circuit} pos#{i}: reconstruction != original (format CASSÉ)")

    raw = sum(len(encode_keyframe(f)) for f in frames)   # raw = 1 keyframe / frame
    avg_ch = sum(change_counts) / N
    max_ch = max(change_counts)
    zero = sum(1 for c in change_counts if c == 0)
    avg_diff_cyc = CYC_DIFF_FIXED + CYC_PER_CHANGE * avg_ch
    max_diff_cyc = CYC_DIFF_FIXED + CYC_PER_CHANGE * max_ch
    kf_apply_cyc = (raw / N) * CYC_KF_PER_BYTE   # coût moyen d'1 keyframe (seek)

    return {
        'circuit': circuit, 'N': N, 'KF': KF,
        'raw': raw,
        'diff_bytes': len(diff_stream),
        'kf_bytes': len(keyframes), 'n_kf': n_keyframes,
        'total': len(diff_stream) + len(keyframes),
        'avg_ch': avg_ch, 'max_ch': max_ch, 'zero_pct': 100 * zero / N,
        'avg_diff_cyc': avg_diff_cyc, 'max_diff_cyc': max_diff_cyc,
        'kf_apply_cyc': kf_apply_cyc,
        'validated': True,
    }


def kb(b): return f"{b/1024:.0f}Ko"


def main(argv):
    ap = argparse.ArgumentParser()
    ap.add_argument('--circuit')
    ap.add_argument('--all', action='store_true')
    ap.add_argument('--S', type=int, default=1)
    ap.add_argument('--KF', type=int, default=64)
    a = ap.parse_args(argv)
    assets = rb.load_assets()
    circuits = rb.list_circuits() if a.all else [a.circuit or '22_hard_5']

    print(f"\n=== FORMAT DIFF (S={a.S}, keyframe tous les {a.KF}) — validé lossless ===")
    print(f"{'circuit':14s}{'pos':>5s}  {'RAW':>7s}  {'diff':>7s}{'+keyf':>7s}{'=total':>8s}"
          f"{'vs raw':>7s}   {'chg.moy/max':>11s}{'diff0%':>7s}   {'cyc/avance moy/max':>18s}")
    tot_raw = tot_total = 0
    for c in circuits:
        r = build(c, a.S, a.KF, assets)
        tot_raw += r['raw']; tot_total += r['total']
        print(f"{c:14s}{r['N']:>5d}  {kb(r['raw']):>7s}  {kb(r['diff_bytes']):>7s}{kb(r['kf_bytes']):>7s}"
              f"{kb(r['total']):>8s}{'÷'+format(r['raw']/r['total'],'.1f'):>7s}   "
              f"{r['avg_ch']:>5.1f}/{r['max_ch']:<3d}  {r['zero_pct']:>5.0f}   "
              f"{r['avg_diff_cyc']:>7.0f} /{r['max_diff_cyc']:>6.0f}")
    if len(circuits) > 1:
        print(f"{'TOTAL':14s}{'':>5s}  {kb(tot_raw):>7s}  {'':>7s}{'':>7s}{kb(tot_total):>8s}"
              f"{'÷'+format(tot_raw/tot_total,'.1f'):>7s}")
    print("\nValidé : pour CHAQUE position, reconstruire (keyframe + diffs) == l'original (byte-exact).")
    print("cyc/avance = coût modélisé d'appliquer 1 diff au Dense_Buffer résident (forward driving).")
    print(f"seek/respawn = charger 1 keyframe (~{int(build(circuits[0],a.S,a.KF,assets)['kf_apply_cyc'])} cyc) + diffs jusqu'à la cible.")


if __name__ == '__main__':
    main(sys.argv[1:])


# ─────────────────────────────────────────────────────────────────────────────
# Packing en pages + index + exemple illustré
# Record (1er octet) :  $00..$60 = DIFF (n lignes changées) | $FE = KEYFRAME | $FF = NEXT-PAGE
#   DIFF     : n(1) min_y(1)  [ Y(1) f(2) w(2) e(2) ] × n
#   KEYFRAME : $FE min_y(1)   [ f(2) w(2) e(2) ] × (96-min_y)
#   NEXT-PAGE: $FF            (mount page+1, ptr = base de page)
# Index[frame] : page(1) addr(2)  -> 3 octets/frame
# ─────────────────────────────────────────────────────────────────────────────
def rec_keyframe(frame):
    my, row = frame
    b = bytearray([0xFE, my & 0xFF])
    for y in range(my, 96):
        f, w, e = row.get(y, (0, 0, 0)); b += struct.pack('>HHH', f, w, e)
    return bytes(b)

def rec_diff(cur_my, changes):
    b = bytearray([len(changes) & 0xFF, cur_my & 0xFF])
    for y, (f, w, e) in changes:
        b += bytes([y]) + struct.pack('>HHH', f, w, e)
    return bytes(b)

def hexs(b, n=None):
    bb = b if n is None else b[:n]
    s = ' '.join(f'{x:02X}' for x in bb)
    return s + (' …' if n and len(b) > n else '')

def illustrate(circuit, start, count, page_size, base, assets):
    frames = frames_of(circuit, 1, assets)
    L = []
    L.append(f"=== EXEMPLE ILLUSTRÉ — circuit {circuit}, frames {start}..{start+count-1}")
    L.append(f"    (page_size={page_size}o pour l'exemple ; en réel = 16384 ; base mount=${base:04X})\n")
    page, ptr, state, state_my = 0, base, {}, 96
    index = []
    for i in range(count):
        fr = frames[start + i]
        if i == 0:
            rec = rec_keyframe(fr); kind = "KEYFRAME"
            state = {y: fr[1].get(y, (0,0,0)) for y in range(fr[0],96)}; state_my = fr[0]
        else:
            cur_my, ch = diff_changes(state_my, state, fr)
            rec = rec_diff(cur_my, ch); kind = f"DIFF ({len(ch)} lignes)"
            for y,cv in ch: state[y]=cv
            state_my = cur_my
        # tient dans la page ? (réserver 1 octet pour le marqueur $FF)
        if ptr + len(rec) > base + page_size - 1:
            L.append(f"  [${page:02X}:${ptr:04X}]  FF                          ; NEXT-PAGE (page pleine -> page suivante)")
            page += 1; ptr = base
        index.append((page, ptr))
        L.append(f"  [${page:02X}:${ptr:04X}]  {hexs(rec, 14):<44s} ; frame {start+i} ({kind}) {len(rec)}o")
        ptr += len(rec)
    L.append("\n  INDEX (page, addr) — 3 octets/frame :")
    for i,(pg,ad) in enumerate(index):
        L.append(f"    frame {start+i:5d} -> page ${pg:02X}  addr ${ad:04X}    (fdb : ${pg:02X}{ad>>8:02X} ${ad&0xFF:02X}..)")
    print("\n".join(L))

if __name__ == '__main__' and '--illustrate' in sys.argv:
    a = rb.load_assets()
    illustrate('22_hard_5', 255, 6, page_size=64, base=0x0000, assets=a)
    sys.exit(0)
