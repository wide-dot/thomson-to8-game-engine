#!/usr/bin/env python3
"""
proto_leftedge_fix.py — Prototype Python du fix fidèle 68k (AVANT l'ASM).

Compare, par scanline, la position du bord gauche de la route sous :
  - MODÈLE ACTUEL  : entry = (K+M+J) - 17 + chunk_shift ; J'/K' depuis header
                     (= 3 sources quantifiées → jitter prouvé sur trace)
  - MODÈLE LEFTEDGE : leftEdge = 80 + neg_product - M*8  (= 68k centerX-demi)
                      J' = leftEdge>>4 ; sub = leftEdge&15 ; clip comme la ladder

But : prouver que le modèle leftEdge donne un bord lisse (0 saut) AVANT de
toucher l'ASM, et vérifier que les couples (K',J') tombent dans le dispatch
réellement implémenté (sinon il faut régénérer les routines).

Usage : python3 tools/proto_leftedge_fix.py <CIRCUIT> <SEG> <NIBBLE> [<LATERAL>]
"""

import sys
import re
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from simulate_dfr_pipeline import (
    parse_circuit, load_perspective_tables, sparse_projection,
    linear_interp, load_persp_recip_paged, dfr_compute_curve, signed16, signed_shr,
)
from oracle_road_position import (
    find_project_root, load_line_offsets, load_lines_table, read_kmj,
)
from lwmap import load_lwmap, find_default_map


CENTER = 80   # px : centre écran TO8 (160/2). leftEdge=CENTER-M*8 → route centrée si neg_product=0


def implemented_dispatch():
    """Set des (K',J') réellement implémentés (routines Road_draw_K*_J* du lwmap)."""
    try:
        syms = load_lwmap(find_default_map())
    except Exception:
        return None
    pat = re.compile(r'^Road_draw_K(\d+)_J(\d+)$')
    s = set()
    for name in syms:
        m = pat.match(name)
        if m:
            s.add((int(m.group(1)), int(m.group(2))))
    return s


def model_current(K, M, J, chunk_shift, sub_pix):
    """entry = N-17+chunk_shift ; J'/K' depuis header (modèle actuel)."""
    N = K + M + J
    entry = max(0, signed16(N - 17 + chunk_shift))
    Kp = max(0, min(10, K - entry))
    Jp = max(0, min(10, entry + 10 - K - M))
    byte_offset = sub_pix >> 2
    # position bord gauche route (px) : window fixe + J' (gauche) + sub
    # road_left = Jp*16 + sub_pix  (window base const ignorée)
    return Jp * 16 + sub_pix, (Kp, Jp)


def model_leftedge(M, neg_product):
    """Fix : un seul pixel leftEdge, décomposé atomiquement + clip ladder."""
    leftEdge = signed16(CENTER + neg_product - M * 8)
    LE = signed_shr(leftEdge, 4)        # asr #4 signé
    sub = leftEdge & 0x0F
    right = LE + M
    Jp = max(0, min(10, LE))
    vis_end = max(0, min(10, right))
    Kp = 10 - vis_end
    F = vis_end - Jp
    core_off = max(0, right - 10)
    # road_left = leftEdge par construction (LE*16 + sub) → lisse
    return LE * 16 + sub, (Kp, Jp), F, core_off, leftEdge


def jumps(seq):
    return [(i, seq[i] - seq[i - 1]) for i in range(1, len(seq)) if abs(seq[i] - seq[i - 1]) >= 16]


def main():
    if len(sys.argv) < 4:
        print("Usage: proto_leftedge_fix.py <CIRCUIT> <SEG> <NIBBLE> [<LATERAL>]")
        sys.exit(1)
    circuit_id, seg, nibble = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
    lateral = int(sys.argv[4]) if len(sys.argv) > 4 else 0

    root = find_project_root()
    segments = parse_circuit(root / 'engine' / 'circuits' / f'{circuit_id}.asm', circuit_id)
    horizon, scaling = load_perspective_tables(root / 'lotus-ste/doc/extraction/unpacked/FILE59.bin')
    paged = load_persp_recip_paged(root / 'engine/projection/Persp_Recip_paged.bin')
    line_off = load_line_offsets(root / 'game-mode/road/generated/road_buffers_externs.inc')
    lines_tab = load_lines_table(root / 'game-mode/road/generated/road_lines_table.asm')
    bin_bytes = (root / 'objects/road-buffers/generated/road_buffers.bin').read_bytes()
    impl = implemented_dispatch()

    chunks_shift = signed_shr(lateral, 4)
    lateral_sub = lateral & 0x0F

    slots, _ = sparse_projection(segments, seg, nibble, horizon, scaling)
    dense = linear_interp(slots, paged)
    ys = sorted(dense.keys())

    print(f"=== PROTO leftEdge : {circuit_id} seg={seg} nibble={nibble} lat={lateral:+d} ===\n")
    print("  Y  | M  | negP | CUR left (K'J') | LEFTEDGE left (K'F'J' off) | impl?")
    print("  ---+----+------+-----------------+----------------------------+------")
    cur_seq, le_seq = [], []
    missing = []
    for y in ys:
        t = dense[y]
        cc = dfr_compute_curve(t['flags'], t['width'], chunks_shift, lateral_sub)
        negp = cc['neg_product']
        line_idx = min(254, t['width'] >> 4)
        K, M, J = read_kmj(bin_bytes, line_off[lines_tab[line_idx][0]]) if line_idx < len(lines_tab) else (5, 0, 12)

        cur_left, (cK, cJ) = model_current(K, M, J, cc['chunk_shift'], cc['sub_pix_out'])
        le_left, (lK, lJ), F, coff, ledge = model_leftedge(M, negp)
        cur_seq.append(cur_left)
        le_seq.append(le_left)

        ok = '' if impl is None else ('ok' if (lK, lJ) in impl else 'MANQUE')
        if ok == 'MANQUE':
            missing.append((lK, lJ))
        print(f"  {y:3d}| {M:2d} | {negp:+4d} |  {cur_left:+5d} ({cK:d},{cJ:d})    |"
              f"   {le_left:+5d}  ({lK:d},{F:d},{lJ:d} off={coff:d})    | {ok}")

    cj = jumps(cur_seq)
    lj = jumps(le_seq)
    print(f"\n=== SYNTHÈSE ===")
    print(f"  MODÈLE ACTUEL  : {len(cj)} sauts ≥16px   (variation totale {sum(abs(cur_seq[i]-cur_seq[i-1]) for i in range(1,len(cur_seq)))}px)")
    print(f"  MODÈLE LEFTEDGE: {len(lj)} sauts ≥16px   (variation totale {sum(abs(le_seq[i]-le_seq[i-1]) for i in range(1,len(le_seq)))}px)")
    if missing:
        print(f"  ⚠ couples (K',J') hors dispatch implémenté : {sorted(set(missing))}")
    else:
        print(f"  ✓ tous les couples (K',J') du modèle leftEdge sont implémentés")


if __name__ == '__main__':
    main()
