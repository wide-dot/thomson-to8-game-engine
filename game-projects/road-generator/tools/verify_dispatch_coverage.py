#!/usr/bin/env python3
"""
verify_dispatch_coverage.py — Vérifie que les routines de dessin couvrent
l'AFFICHAGE de toutes les lignes à toutes les positions nécessaires (amplitude),
sans routine manquante ni débordement de buffer cœur.

Pour chaque line_idx (0..254, = largeur) :
  - M = nb de chunks cœur du buffer
  - on balaie leftEdge_chunks (LE) sur toute l'amplitude possible
  - dispatch (modèle leftEdge déployé) :
        right   = LE + M
        J'      = clamp(LE, 0, 10)
        vis_end = clamp(right, 0, 10)   ;  K' = 10 - vis_end
        F       = 10 - K' - J'  (= vis_end - J')
        coreOff = max(0, right - 10)
  - VÉRIFS :
      (1) routine Road_draw_K{K'}_J{J'} existe
      (2) F >= 0
      (3) si F > 0 : coreOff >= 0 ET coreOff + F <= M  (pas de débordement cœur)
  - + vérifie que les 4 variants sous-pixel (RAMA_s0/s1, RAMB_s0/s1) existent
    pour la ligne.

Reporte aussi l'amplitude RÉELLE de LE observée en jeu (sim, virage + latérale max).
"""

import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from lwmap import load_lwmap, find_default_map
from oracle_road_position import (
    find_project_root, load_line_offsets, load_lines_table, read_kmj,
)


def build_routine_set(syms):
    pat = re.compile(r'^Road_draw_K(\d+)_J(\d+)$')
    s = set()
    for name in syms:
        m = pat.match(name)
        if m:
            s.add((int(m.group(1)), int(m.group(2))))
    return s


def dispatch(LE, M):
    """Reproduit DFR_dispatch_and_draw (modèle leftEdge déployé)."""
    right = LE + M
    Jp = max(0, min(10, LE))
    vis_end = max(0, min(10, right))
    Kp = 10 - vis_end
    F = 10 - Kp - Jp
    coreOff = max(0, right - 10)
    return Kp, Jp, F, coreOff


def real_amplitude(root):
    """LE réel observé : sim sur circuit dur, balayage seg/nibble × latérale max."""
    try:
        from simulate_dfr_pipeline import (
            parse_circuit, load_perspective_tables, sparse_projection,
            linear_interp, load_persp_recip_paged, dfr_compute_curve, signed_shr,
        )
    except ImportError:
        return None
    horizon, scaling = load_perspective_tables(root/'lotus-ste/doc/extraction/unpacked/FILE59.bin')
    paged = load_persp_recip_paged(root/'engine/projection/Persp_Recip_paged.bin')
    line_off = load_line_offsets(root/'game-mode/road/generated/road_buffers_externs.inc')
    lines_tab = load_lines_table(root/'game-mode/road/generated/road_lines_table.asm')
    buf = (root/'objects/road-buffers/generated/road_buffers.bin').read_bytes()
    lo, hi = 999, -999
    for circ in ('22_hard_5', '27_hard_10'):
        cpath = root/'engine'/'circuits'/f'{circ}.asm'
        if not cpath.exists():
            continue
        segs = parse_circuit(cpath, circ)
        for seg in range(0, 240, 20):
            for lat in (192, -192):
                cs, ls = signed_shr(lat, 4), lat & 0x0F
                try:
                    slots, _ = sparse_projection(segs, seg, 8, horizon, scaling)
                    dense = linear_interp(slots, paged)
                except Exception:
                    continue
                for y, t in dense.items():
                    w = t['width']; li = min(254, w >> 4)
                    if li >= len(lines_tab):
                        continue
                    _, M, _ = read_kmj(buf, line_off[lines_tab[li][0]])
                    cc = dfr_compute_curve(t['flags'], w, cs, ls)
                    leftEdge = 80 + cc['neg_product'] - M * 8   # formule ASM déployée
                    LE = signed_shr(leftEdge, 4)
                    lo, hi = min(lo, LE), max(hi, LE)
    return (lo, hi) if hi > -999 else None


def main():
    root = find_project_root()
    syms = load_lwmap(find_default_map())
    routines = build_routine_set(syms)
    line_off = load_line_offsets(root/'game-mode/road/generated/road_buffers_externs.inc')
    lines_tab = load_lines_table(root/'game-mode/road/generated/road_lines_table.asm')
    buf = (root/'objects/road-buffers/generated/road_buffers.bin').read_bytes()

    print(f"# {len(routines)} routines Road_draw présentes ; {len(lines_tab)} lignes dans la table")

    # amplitude réelle
    amp = real_amplitude(root)
    if amp:
        print(f"# Amplitude LE réelle observée (sim virages + latérale ±192) : LE ∈ [{amp[0]}, {amp[1]}]")
    # on balaie LARGE pour couvrir aussi les extrêmes théoriques
    LE_LO, LE_HI = -20, 30

    missing_routines = set()
    overflow_cases = []   # (li, M, LE, Kp, Jp, F, coreOff)
    bad_variant_lines = []
    Kp_max = Jp_max = 0

    for li in range(len(lines_tab)):
        labels = lines_tab[li]                      # [RAMA_s0, RAMA_s1, RAMB_s0, RAMB_s1]
        # variants : 4 buffers doivent exister
        if len(labels) != 4 or any(l not in line_off for l in labels):
            bad_variant_lines.append(li)
            continue
        _, M, _ = read_kmj(buf, line_off[labels[0]])
        for LE in range(LE_LO, LE_HI + 1):
            Kp, Jp, F, coreOff = dispatch(LE, M)
            Kp_max = max(Kp_max, Kp); Jp_max = max(Jp_max, Jp)
            if F < 0:
                overflow_cases.append(('F<0', li, M, LE, Kp, Jp, F, coreOff))
                continue
            if (Kp, Jp) not in routines:
                missing_routines.add((Kp, Jp))
            if F > 0 and (coreOff < 0 or coreOff + F > M):
                overflow_cases.append(('overread', li, M, LE, Kp, Jp, F, coreOff))

    print()
    print("=== RÉSULTATS ===")
    print(f"  K' max produit : {Kp_max} ; J' max produit : {Jp_max}  (triangle K'+J'<=10)")
    print(f"  routines (K',J') MANQUANTES : {sorted(missing_routines) if missing_routines else 'AUCUNE ✓'}")
    print(f"  cas de débordement cœur / F<0 : {len(overflow_cases)}")
    for c in overflow_cases[:12]:
        print(f"      {c[0]}: line {c[1]} M={c[2]} LE={c[3]} -> K'={c[4]} J'={c[5]} F={c[6]} coreOff={c[7]}")
    print(f"  lignes avec variants sous-pixel manquants : {bad_variant_lines if bad_variant_lines else 'AUCUNE ✓'}")
    print()
    ok = not missing_routines and not overflow_cases and not bad_variant_lines
    print("  >>> COUVERTURE COMPLÈTE ✓" if ok else "  >>> TROUS DÉTECTÉS ✗ (voir ci-dessus)")


if __name__ == '__main__':
    main()
