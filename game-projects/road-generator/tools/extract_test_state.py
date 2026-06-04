#!/usr/bin/env python3
"""
Extract test init state for static-frame validation of DrawFrameRoad.

Usage : extract_test_state.py [seg_idx] [nibble]

Pour un point donné dans le circuit (= seg_idx + nibble), affiche :
  - Les valeurs à hardcoder dans LotusCarState (= segment_idx, track_pos[2]).
  - Le tableau per-scanline attendu :
      substep | slot_Y (= scanline) | slot_X (D2 cumul) | width | curve_chunk_shift
  - Une visualisation ASCII de la route attendue (= centerX_offset au fil de la
    profondeur).

Permet de comparer ce qu'on devrait voir avec ce qui s'affiche réellement à
l'écran sur une frame figée.
"""

import sys
from pathlib import Path

# Réutilise les helpers du simulateur principal
sys.path.insert(0, str(Path(__file__).resolve().parent))
from simulate_sparse_projection import (
    parse_circuit,
    decode_segment,
    load_perspective_tables,
    project_segment,
    signed16,
)


def main():
    seg_idx = int(sys.argv[1]) if len(sys.argv) > 1 else 32
    nibble = int(sys.argv[2]) if len(sys.argv) > 2 else 8

    project_root = Path('/sessions/pensive-exciting-rubin/mnt/thomson-to8-game-engine/game-projects/road-generator')
    if not project_root.exists():
        project_root = Path('/Users/benoitrousseau/Documents/Claude/Projects/thomson-to8-game-engine/game-projects/road-generator')

    circuit_asm = project_root / 'engine' / 'circuits' / '23_hard_6.asm'
    file59 = project_root / 'lotus-ste' / 'doc' / 'extraction' / 'unpacked' / 'FILE59.bin'

    segments = parse_circuit(circuit_asm)
    NB_SEG = 256
    main_segs = [s for s in segments if s[0] < NB_SEG]
    horizon, scaling = load_perspective_tables(file59)

    # Info sur seg_idx + voisins (= seg+1..seg+8 visibles)
    print(f"═══ Test state : segment {seg_idx}, nibble {nibble} ═══")
    print()
    print(f"Visible segments (= seg .. seg+8) :")
    print(f"  idx   curve   pitch   flags")
    for off in range(9):
        s = main_segs[(seg_idx + off) % NB_SEG][1]
        cv, pt, pit, start = decode_segment(s)
        flags = ('PIT ' if pit else '    ') + ('START' if start else '     ')
        marker = '  ← player here' if off == 0 else ''
        print(f"  {seg_idx + off:3d}   {cv:+4d}   {pt:+4d}   {flags}{marker}")
    print()

    # Simule la projection
    slots = project_segment(main_segs, seg_idx, nibble, horizon, scaling, NB_SEG)
    print(f"Generated {len(slots)} substeps avant horizon.")
    print()

    # Tableau per-scanline
    print(f"═══ Tableau per-scanline ═══")
    print(f"  sub | scanline | slot.X    | width | curve_shift_px | chunks (>>4)")
    print(f"  ----+----------+-----------+-------+----------------+-------------")
    for i, (X_raw, Y) in enumerate(slots):
        if i >= 32:
            print(f"  ... ({len(slots) - 32} substeps de plus)")
            break
        X_signed = signed16(X_raw & 0xFFFC)
        # width = scaling[i] (= per-substep depth-indexed)
        width = scaling[i] if i < len(scaling) else 0
        # curve_chunk_shift = (slot.X × width × 2) >> 16, puis >> 4
        product = X_signed * width * 2
        offset_px = product >> 16  # Python signed shift
        chunks = offset_px >> 4 if offset_px >= 0 else -((-offset_px + 15) >> 4)
        print(f"  {i:3d} | Y={Y:4d}   | {X_signed:+7d}   | {width:5d} | {offset_px:+6d} px      | {chunks:+3d}")
    print()

    # Visualisation ASCII (= horizon en haut, près caméra en bas)
    print(f"═══ Vue ASCII (horizon en haut, near caméra en bas) ═══")
    print(f"  Chaque ligne = un substep. # marque le centre de la route.")
    print(f"  | = centre écran. Largeur = ±160 px → 80 cols (= 4 px/col).")
    width_screen = 80
    # Reverse pour avoir horizon en haut
    drawable = [(i, X, Y) for i, (X, Y) in enumerate(slots) if Y < 96][::-1]
    for i, X_raw, Y in drawable[:48]:
        X_signed = signed16(X_raw & 0xFFFC)
        width = scaling[i] if i < len(scaling) else 0
        offset_px = (X_signed * width * 2) >> 16
        col = width_screen // 2 + offset_px // 4
        col = max(0, min(width_screen - 1, col))
        line = [' '] * width_screen
        line[width_screen // 2] = '|'
        line[col] = '#'
        print(f"  Y={Y:3d} sub={i:2d}  " + ''.join(line))
    print()

    # Init values pour LotusCarState
    print(f"═══ Init values à hardcoder ═══")
    print(f"  LotusCarState.segment_idx  = ${seg_idx:04X}  (= {seg_idx})")
    track_pos_byte2 = nibble << 4
    print(f"  LotusCarState.track_pos+2  = ${track_pos_byte2:02X}    (= nibble {nibble} << 4)")
    print(f"  LotusCarState.track_pos+3  = $00")
    print()
    print(f"Code patch (player-one-init.asm ou MainLoop init) :")
    print(f"  ldu   #PlayerOne_State")
    print(f"  ldd   #{seg_idx}")
    print(f"  std   LotusCarState.segment_idx,u")
    print(f"  ldd   #${track_pos_byte2:02X}00")
    print(f"  std   LotusCarState.track_pos+2,u")


if __name__ == '__main__':
    main()
