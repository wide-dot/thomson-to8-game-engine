#!/usr/bin/env python3
"""
road_analyze.py — Analyse des données bakées pour trouver le MEILLEUR stockage.

Optimise DEUX axes en même temps : (1) taille sur disque, (2) coût de copie vers
la zone résidente au runtime. Mesure les redondances réelles par circuit et chiffre
plusieurs schémas de stockage (taille + octets copiés/avance).

Réutilise road_bake (project/bake) — même source de vérité.

Usage :
  .venv/bin/python3 tools/road_analyze.py [--circuit 22_hard_5 | --all] [--S 1]
"""
import sys, argparse, struct
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import road_bake as rb
from simulate_dfr_pipeline import parse_circuit

SUB = 16


def frames_of(circuit, S, assets):
    """Liste des frames échantillonnées (/S). Chaque frame = dict {Y:(flags,width,extra)} + min_y."""
    segs = parse_circuit(rb.ROOT / 'engine/circuits' / f'{circuit}.asm', circuit)
    nb = rb.circuit_nb_segments(circuit)
    npos = nb * SUB
    out = []
    for p in range(0, npos, S):
        dense, min_y = rb.project_pos(segs, nb, p, assets)
        row = {y: (dense[y]['flags'] & 0xFFFF, dense[y]['width'] & 0xFFFF,
                   dense[y].get('extra', 0) & 0xFFFF) for y in dense}
        out.append((min_y, row))
    return out, nb, npos


def baked_bytes(min_y, row):
    b = bytearray([min_y & 0xFF])
    for y in range(min_y, 96):
        f, w, e = row.get(y, (0, 0, 0))
        b += struct.pack('>HHH', f, w, e)
    return bytes(b)


def diff_lines(a, b):
    """Nb de scanlines Y qui diffèrent entre 2 frames (alignées par Y absolu)."""
    ya, ra = a
    yb, rb_ = b
    lo = min(ya, yb)
    n = 0
    for y in range(lo, 96):
        if ra.get(y, (0, 0, 0)) != rb_.get(y, (0, 0, 0)):
            n += 1
    return n


def analyze(circuit, S, assets):
    frames, nb, npos = frames_of(circuit, S, assets)
    N = len(frames)
    sizes = [len(baked_bytes(*f)) for f in frames]
    raw = sum(sizes)

    # 1. dédup
    seen = {}
    uniq_ids = []
    for f in frames:
        b = baked_bytes(*f)
        if b not in seen:
            seen[b] = len(seen)
        uniq_ids.append(seen[b])
    n_uniq = len(seen)
    dedup_blob = sum(len(b) for b in seen)
    dedup_index = N * 2  # uint16 frame-id par position

    # 2. diff frame->frame (avances séquentielles)
    zero = 0
    dlines = []
    for i in range(1, N):
        d = diff_lines(frames[i - 1], frames[i])
        dlines.append(d)
        if d == 0:
            zero += 1
    avg_d = sum(dlines) / len(dlines) if dlines else 0
    max_d = max(dlines) if dlines else 0

    # 3. redondance par colonne (identique à la frame préc.)
    def col(frame, idx):
        my, row = frame
        return tuple(row.get(y, (0, 0, 0))[idx] for y in range(my, 96))
    crep = [0, 0, 0]
    for i in range(1, N):
        for c in range(3):
            if col(frames[i], c) == col(frames[i - 1], c):
                crep[c] += 1

    # 4. min_y
    avg_lines = sum(96 - f[0] for f in frames) / N

    # ── schémas (taille + octets copiés/avance) ──
    # raw entrelacé : copie frame entière à chaque avance
    raw_copy = raw / N
    # dédup + skip-si-inchangé : ne copie que si la frame change
    changes = sum(1 for i in range(1, N) if uniq_ids[i] != uniq_ids[i - 1])
    dedup_size = dedup_blob + dedup_index
    dedup_copy = (changes / (N - 1)) * (raw / N) if N > 1 else 0
    # diff forward + keyframes (1 keyframe / KF) : taille = keyframes + diffs ;
    # copie = octets changés (1 octet Y + 6 octets triplet par ligne changée)
    KF = 64
    kf_bytes = sum(sizes[i] for i in range(0, N, KF))
    diff_bytes = sum((d * 7) for d in dlines)            # ~7 o par ligne changée
    diff_size = kf_bytes + diff_bytes + dedup_index       # + index position->keyframe/diff
    diff_copy = (sum(dlines) / (N - 1)) * 7 if N > 1 else 0

    return {
        'circuit': circuit, 'nb': nb, 'positions': N,
        'avg_lines': avg_lines,
        'uniq': n_uniq, 'dedup_pct': 100 * n_uniq / N,
        'zero_diff_pct': 100 * zero / (N - 1) if N > 1 else 0,
        'avg_dlines': avg_d, 'max_dlines': max_d,
        'col_rep': [100 * c / (N - 1) for c in crep] if N > 1 else [0, 0, 0],
        'raw': raw, 'raw_copy': raw_copy,
        'dedup_size': dedup_size, 'dedup_copy': dedup_copy,
        'diff_size': diff_size, 'diff_copy': diff_copy,
    }


def kb(b): return f"{b/1024:.0f}Ko"


def main(argv):
    ap = argparse.ArgumentParser()
    ap.add_argument('--circuit')
    ap.add_argument('--all', action='store_true')
    ap.add_argument('--S', type=int, default=1)
    a = ap.parse_args(argv)
    assets = rb.load_assets()
    circuits = rb.list_circuits() if a.all else [a.circuit or '22_hard_5']

    print(f"\n=== REDONDANCE (S={a.S}) ===")
    print(f"{'circuit':14s}{'pos':>5s}{'lignes':>7s}{'uniq%':>7s}{'diff0%':>7s}"
          f"{'dl.moy':>7s}{'dl.max':>7s}   {'col_rep flags/wid/ext':>22s}")
    res = []
    for c in circuits:
        r = analyze(c, a.S, assets); res.append(r)
        print(f"{c:14s}{r['positions']:>5d}{r['avg_lines']:>7.0f}{r['dedup_pct']:>7.0f}"
              f"{r['zero_diff_pct']:>7.0f}{r['avg_dlines']:>7.1f}{r['max_dlines']:>7d}   "
              f"{r['col_rep'][0]:>6.0f}/{r['col_rep'][1]:>3.0f}/{r['col_rep'][2]:>3.0f} %")

    print(f"\n=== TAILLE & COÛT-COPIE par schéma (brut, avant ZX0) ===")
    print(f"{'circuit':14s}  {'RAW':>18s}   {'DEDUP':>18s}   {'DIFF+keyfr':>18s}")
    print(f"{'':14s}  {'taille / copie':>18s}   {'taille / copie':>18s}   {'taille / copie':>18s}")
    for r in res:
        print(f"{r['circuit']:14s}  {kb(r['raw']):>8s} /{r['raw_copy']:>5.0f}o   "
              f"{kb(r['dedup_size']):>8s} /{r['dedup_copy']:>5.0f}o   "
              f"{kb(r['diff_size']):>8s} /{r['diff_copy']:>5.0f}o")
    print("\nLecture : 'copie' = octets à écrire en zone résidente PAR AVANCE de position")
    print("(moyenne). DIFF = 0 sur le plat, petit en courbe -> copie quasi gratuite.")


if __name__ == '__main__':
    main(sys.argv[1:])
