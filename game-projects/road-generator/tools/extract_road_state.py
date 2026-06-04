#!/usr/bin/env python3
"""
extract_road_state.py — Extrait l'état SP/LinearInterp/DFR par frame depuis
une trace dcmoto, en utilisant le lwmap pour mapper auto les adresses.

Adresses résolues dynamiquement depuis le main.lwmap → pas de hardcode,
fonctionne quel que soit le layout après rebuild.

USAGE :

    # Toutes les frames, dump sparse + dense
    python3 tools/extract_road_state.py --trace dist/dcmoto_trace.txt

    # Frame 5 seulement, format détaillé
    python3 tools/extract_road_state.py --trace dist/dcmoto_trace.txt --frame 5

    # Toutes les frames, output CSV pour analyse
    python3 tools/extract_road_state.py --trace dist/dcmoto_trace.txt \\
        --output csv --csv-out frames.csv

    # Map alternatif
    python3 tools/extract_road_state.py --trace ... --map autre/path.lwmap

    # Limiter à N frames pour tester rapide sur grosse trace
    python3 tools/extract_road_state.py --trace ... --max-frames 10

    # Comparer avec simulateur Python pour la frame N
    python3 tools/extract_road_state.py --trace ... --frame 3 --compare-sim \\
        --seg 59 --nibble 3

OUTPUT :
    Pour chaque frame, affiche :
    - Cycle d'entrée SP / LI / DFR
    - Sparse_Buffer : N slots avec Y/X/scaling/D0a
    - Dense_Buffer : triplets non-nuls
    - Stats : largeur min/max, deltas, plateaux Y (= signal du bug SP_mul)
"""

import argparse
import sys
import csv
from pathlib import Path

# Permet l'exécution depuis n'importe où
sys.path.insert(0, str(Path(__file__).resolve().parent))

from lwmap import load_lwmap, find_default_map, require
from dcmoto_trace import (
    iter_lines, find_calls, dump_buffer_writes,
    decode_dense_triplets, decode_sparse_slots,
)


def iter_frames(trace_path, syms, max_frames=None):
    """Stream toutes les frames en UN SEUL PASS sur la trace (= O(N)).

    Pour chaque appel à SparseProjection détecté, accumule en mémoire :
    - les writes vers Sparse_Buffer (pendant SP)
    - les writes vers Dense_Buffer (pendant LI)
    - les writes vers Proj_count, Proj_min_y
    - les cycles d'entrée SP/LI/DFR

    À la frame suivante (= nouveau SP entry) OU à la fin du trace, yield
    le dict frame complet et reset les accumulateurs.

    Args :
        max_frames : si fourni, stop après N frames (=tests rapides).

    Yields : dict avec mêmes clés que extract_frame() ancien.
    """
    sp_addr = syms['SparseProjection']
    li_addr = syms['LinearInterp']
    dfr_addr = syms['DrawFrameRoad']
    sparse_buf = syms['Sparse_Buffer']
    sparse_buf_end = sparse_buf + 1280
    dense_buf = syms['Dense_Buffer']
    dense_buf_end = dense_buf + 1152
    proj_count_addr = syms['Proj_count']
    proj_min_y_addr = syms.get('Proj_min_y')
    proj_count_op = f'${proj_count_addr:04X}'
    proj_min_y_op = f'${proj_min_y_addr:04X}' if proj_min_y_addr else None

    # État courant
    in_frame = False
    phase = 'idle'      # idle / sp / li / dfr
    sp_entry = li_entry = dfr_entry = None
    sp_entry_cyc = None
    sparse_mem = {}
    dense_mem = {}
    proj_count = None
    proj_min_y = None
    frame_count = 0

    def emit_frame():
        nonlocal frame_count
        n_slots = proj_count if proj_count else 72
        slots = decode_sparse_slots(sparse_mem, sparse_buf, n_slots)
        triplets = decode_dense_triplets(dense_mem, dense_buf)
        frame_count += 1
        return {
            'frame_idx': frame_count - 1,
            'sp_call': (sp_entry, li_entry - 1 if li_entry else None),
            'li_call': (li_entry, dfr_entry - 1 if (li_entry and dfr_entry) else None),
            'dfr_call': (dfr_entry, None) if dfr_entry else None,
            'sp_entry_cyc': sp_entry_cyc,
            'proj_count': proj_count,
            'proj_min_y': proj_min_y,
            'sparse_slots': slots,
            'dense_triplets': triplets,
        }

    for tl in iter_lines(trace_path):
        # === Détection transitions de phase ===
        if tl.pc == sp_addr:
            if in_frame:
                # Nouvelle SP : émettre la frame précédente
                yield emit_frame()
                if max_frames and frame_count >= max_frames:
                    return
                sparse_mem = {}
                dense_mem = {}
                proj_count = None
                proj_min_y = None
            in_frame = True
            phase = 'sp'
            sp_entry = tl.line_no
            sp_entry_cyc = tl.total_cyc
            li_entry = dfr_entry = None
            continue

        if not in_frame:
            continue

        if phase == 'sp' and tl.pc == li_addr:
            phase = 'li'
            li_entry = tl.line_no
            continue
        if phase in ('sp', 'li') and tl.pc == dfr_addr:
            phase = 'dfr'
            dfr_entry = tl.line_no
            continue

        # === Capture writes ===
        m = tl.mnem
        op = tl.operand

        # Sparse buffer writes (phase 'sp' uniquement, performance)
        if phase == 'sp' and m in ('STD', 'STA', 'STB'):
            _maybe_capture_store(tl, m, op, sparse_buf, sparse_buf_end, sparse_mem)

        # Dense buffer writes (phase 'li' uniquement)
        if phase == 'li' and m in ('STD', 'STA', 'STB'):
            _maybe_capture_store(tl, m, op, dense_buf, dense_buf_end, dense_mem)

        # Proj_count + Proj_min_y (= captured during 'sp')
        if phase == 'sp':
            if m == 'STD' and op == proj_count_op:
                proj_count = tl.d
            elif proj_min_y_op and m in ('STA', 'STB') and op == proj_min_y_op:
                proj_min_y = (tl.d >> 8) & 0xFF if m == 'STA' else tl.d & 0xFF

    # Émettre la dernière frame si elle est complète
    if in_frame:
        yield emit_frame()


def _maybe_capture_store(tl, m, op, buf_start, buf_end, mem):
    """Helper : capture un store vers mem dict si addr in [buf_start, buf_end)."""
    addr = None
    is_word = (m == 'STD')

    # Modes indirect Y/X/U
    if ',Y++' in op:
        addr = (tl.y - 2) & 0xFFFF
    elif ',Y+' in op:
        addr = (tl.y - 1) & 0xFFFF
    elif ',--Y' in op:
        addr = tl.y
    elif ',-Y' in op:
        addr = tl.y
    elif op == ',Y':
        addr = tl.y
    elif ',U++' in op:
        addr = (tl.u - 2) & 0xFFFF
    elif ',--U' in op:
        addr = tl.u
    elif op == ',U':
        addr = tl.u
    elif ',X++' in op:
        addr = (tl.x - 2) & 0xFFFF
    elif op == ',X':
        addr = tl.x
    elif op.startswith('$'):
        try:
            addr = int(op[1:], 16)
        except ValueError:
            return
    else:
        return

    if addr is None:
        return

    if is_word:
        if buf_start <= addr < buf_end:
            mem[addr] = (tl.d >> 8) & 0xFF
        if buf_start <= addr + 1 < buf_end:
            mem[addr + 1] = tl.d & 0xFF
    else:
        if buf_start <= addr < buf_end:
            mem[addr] = (tl.d >> 8) & 0xFF if m == 'STA' else tl.d & 0xFF


def extract_frame(trace_path, syms, frame_idx):
    """Extrait UNE frame spécifique. Utilise iter_frames + skip."""
    for i, frame in enumerate(iter_frames(trace_path, syms, max_frames=frame_idx + 1)):
        if i == frame_idx:
            return frame
    return None


# ─────────────────────────────────────────────────────────────────────────────
# Statistiques + reporting
# ─────────────────────────────────────────────────────────────────────────────

def compute_frame_stats(frame):
    """Calcule stats utiles : largeur min/max, plateaux Y dans sparse, etc."""
    slots = frame['sparse_slots']
    triplets = frame['dense_triplets']

    # Plateaux Y dans sparse (= indicateur du bug SP_mul précision)
    ys = [s['Y'] for s in slots]
    plateaus = []
    if ys:
        run_start = 0
        for i in range(1, len(ys)):
            if ys[i] != ys[run_start]:
                if i - run_start >= 3:
                    plateaus.append({'y': ys[run_start], 'count': i - run_start,
                                     'slot_range': (run_start, i - 1)})
                run_start = i
        if len(ys) - run_start >= 3:
            plateaus.append({'y': ys[run_start], 'count': len(ys) - run_start,
                             'slot_range': (run_start, len(ys) - 1)})

    # Widths
    widths = sorted([t['width'] for t in triplets.values()])
    width_jumps = []
    sorted_ys = sorted(triplets.keys())
    for i in range(1, len(sorted_ys)):
        prev = triplets[sorted_ys[i - 1]]['width']
        cur = triplets[sorted_ys[i]]['width']
        delta = cur - prev
        if abs(delta) > 30:
            width_jumps.append({'y': sorted_ys[i], 'from': prev, 'to': cur, 'delta': delta})

    return {
        'n_slots': len(slots),
        'n_triplets': len(triplets),
        'min_y_sparse': min(ys) if ys else None,
        'max_y_sparse': max(ys) if ys else None,
        'min_width': widths[0] if widths else None,
        'max_width': widths[-1] if widths else None,
        'plateaus': plateaus,
        'width_jumps': width_jumps,
    }


def print_frame_detailed(frame, stats):
    print(f"╔═══ FRAME {frame['frame_idx']} ═══════════════════════════════════╗")
    print(f"║ cycle entry SP : {frame['sp_entry_cyc']:>10}")
    print(f"║ SP   lines : {frame['sp_call']}")
    print(f"║ LI   lines : {frame['li_call']}")
    print(f"║ DFR  lines : {frame['dfr_call']}")
    print(f"║ Proj_count : {frame['proj_count']}   Proj_min_y : {frame['proj_min_y']}")
    print(f"╠══ Sparse_Buffer : {stats['n_slots']} slots, Y range [{stats['min_y_sparse']}..{stats['max_y_sparse']}]")

    slots = frame['sparse_slots']
    print(f"║   idx | Y   | X      | Y_min | D0a   ")
    print(f"║   ----+-----+--------+-------+-------")
    for i, s in enumerate(slots):
        marker = ''
        for p in stats['plateaus']:
            if p['slot_range'][0] <= i <= p['slot_range'][1]:
                marker = f' ◄ plateau Y={p["y"]}×{p["count"]}'
                break
        print(f"║   {i:3d} | {s['Y']:3d} | {s['X']:+6d} | {s['Y_min']:5d} | {s['D0a']:+5d}{marker}")

    if stats['plateaus']:
        print(f"╠══ PLATEAUX Y détectés (≥3 substeps même Y) : {len(stats['plateaus'])}")
        for p in stats['plateaus']:
            print(f"║   Y={p['y']:3d} : {p['count']} substeps consécutifs (slot {p['slot_range'][0]}..{p['slot_range'][1]})")
        print(f"║   → cause widths non-smooth (= bug précision SP_mul si présent)")

    print(f"╠══ Dense_Buffer : {stats['n_triplets']} triplets, width [{stats['min_width']}..{stats['max_width']}]")
    triplets = frame['dense_triplets']
    print(f"║   Y   | flags  | width | extra  | Δw")
    print(f"║   ----+--------+-------+--------+------")
    prev_w = None
    for y in sorted(triplets.keys()):
        t = triplets[y]
        dw = '' if prev_w is None else f'  {t["width"] - prev_w:+d}'
        print(f"║   {y:3d} | {t['flags']:+6d} | {t['width']:5d} | {t['extra']:+6d} |{dw}")
        prev_w = t['width']

    if stats['width_jumps']:
        print(f"╠══ SAUTS WIDTH (>30 px) : {len(stats['width_jumps'])}")
        for j in stats['width_jumps']:
            print(f"║   Y={j['y']:3d} : {j['from']} → {j['to']} (Δ={j['delta']:+d})")
    print(f"╚════════════════════════════════════════════════════════════════╝")


def print_frame_summary(frame, stats):
    """Une ligne par frame."""
    n_plateau = len(stats['plateaus'])
    max_plat = max((p['count'] for p in stats['plateaus']), default=0)
    n_jumps = len(stats['width_jumps'])
    print(f"  Frame {frame['frame_idx']:>3} | cyc={frame['sp_entry_cyc']:>10} | "
          f"slots={stats['n_slots']:>3} | dense={stats['n_triplets']:>3} | "
          f"Y_min={stats['min_y_sparse']:>3} | "
          f"plateau={n_plateau} (max×{max_plat}) | "
          f"jumps>30={n_jumps}")


# ─────────────────────────────────────────────────────────────────────────────
# CLI
# ─────────────────────────────────────────────────────────────────────────────

def main():
    ap = argparse.ArgumentParser(
        description='Extrait l\'état SP/LI/DFR par frame depuis trace dcmoto.',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    ap.add_argument('--trace', required=True, help='Path vers dcmoto_trace.txt')
    ap.add_argument('--map', default=None,
                    help='Path vers main.lwmap (default: auto-détecté)')
    ap.add_argument('--frame', type=int, default=None,
                    help='Extraire une frame spécifique (1-based). Sans cet '
                         'arg : extrait toutes les frames en mode résumé.')
    ap.add_argument('--max-frames', type=int, default=None,
                    help='Limite le nb de frames extraites (debug rapide).')
    ap.add_argument('--output', choices=['text', 'csv'], default='text')
    ap.add_argument('--csv-out', default='road_state.csv',
                    help='Fichier CSV destination (si --output csv)')
    ap.add_argument('--compare-sim', action='store_true',
                    help='Compare avec simulateur Python pour la frame extraite.')
    ap.add_argument('--seg', type=int, default=None,
                    help='Pour --compare-sim : segment_idx Python sim')
    ap.add_argument('--nibble', type=int, default=None,
                    help='Pour --compare-sim : nibble Python sim')
    ap.add_argument('--circuit', default=None,
                    help='Pour --compare-sim : circuit_id (e.g., 22_hard_5). '
                         'Si absent, auto-détecté via le symbol Circuit_<id>_segments '
                         'dans le lwmap.')
    args = ap.parse_args()

    # Load lwmap
    map_path = args.map or find_default_map()
    syms = load_lwmap(map_path)
    print(f"# lwmap : {map_path} ({len(syms)} symbols)")

    # Verify required symbols
    try:
        require(syms, 'SparseProjection', 'LinearInterp', 'DrawFrameRoad',
                'Sparse_Buffer', 'Dense_Buffer', 'Proj_count')
    except KeyError as e:
        print(f"ERREUR : {e}", file=sys.stderr)
        sys.exit(1)

    print(f"# SparseProjection=${syms['SparseProjection']:04X}  "
          f"LinearInterp=${syms['LinearInterp']:04X}  "
          f"DrawFrameRoad=${syms['DrawFrameRoad']:04X}")
    print(f"# Sparse_Buffer=${syms['Sparse_Buffer']:04X}  "
          f"Dense_Buffer=${syms['Dense_Buffer']:04X}")
    print()

    if args.frame is not None:
        # Mode single frame détaillé
        frame = extract_frame(args.trace, syms, args.frame - 1)
        if frame is None:
            print(f"ERREUR : frame {args.frame} introuvable dans la trace", file=sys.stderr)
            sys.exit(1)
        stats = compute_frame_stats(frame)
        print_frame_detailed(frame, stats)

        if args.compare_sim:
            _do_compare_sim(frame, args.seg, args.nibble, syms, args.circuit)
        return

    # Mode toutes-frames : résumé une ligne par frame
    print(f"=== Résumé toutes frames (CSV: {args.csv_out if args.output == 'csv' else 'no'}) ===")
    print(f"  Frame  | cycle SP   | slots | dense | Y_min | plateaux | sauts>30")
    print(f"  -------+------------+-------+-------+-------+----------+---------")

    csv_writer = None
    csv_file = None
    if args.output == 'csv':
        csv_file = open(args.csv_out, 'w', newline='')
        csv_writer = csv.writer(csv_file)
        csv_writer.writerow([
            'frame_idx', 'cycle_entry_sp', 'proj_count', 'proj_min_y',
            'n_slots', 'n_triplets',
            'min_y_sparse', 'max_y_sparse',
            'min_width', 'max_width',
            'n_plateaus', 'max_plateau_count',
            'n_width_jumps',
        ])

    # Single-pass O(N) sur toute la trace
    n_frames = 0
    for frame in iter_frames(args.trace, syms, max_frames=args.max_frames):
        n_frames += 1
        stats = compute_frame_stats(frame)
        print_frame_summary({**frame, 'frame_idx': n_frames}, stats)
        if csv_writer:
            csv_writer.writerow([
                n_frames, frame['sp_entry_cyc'], frame['proj_count'],
                frame['proj_min_y'],
                stats['n_slots'], stats['n_triplets'],
                stats['min_y_sparse'], stats['max_y_sparse'],
                stats['min_width'], stats['max_width'],
                len(stats['plateaus']),
                max((p['count'] for p in stats['plateaus']), default=0),
                len(stats['width_jumps']),
            ])

    if csv_file:
        csv_file.close()
        print(f"\n→ CSV écrit : {args.csv_out} ({n_frames} frames)")
    else:
        print(f"\nTotal : {n_frames} frames analysées")


def _do_compare_sim(frame, seg, nibble, syms=None, circuit_override=None):
    """Compare une frame runtime avec la sortie du simulateur Python.

    Détermine le circuit dans cet ordre :
      1. --circuit CLI explicite
      2. Auto-détection via le lwmap : cherche Circuit_<id>_segments
      3. Erreur si aucun trouvé
    """
    if seg is None or nibble is None:
        print("# --compare-sim nécessite --seg N --nibble N", file=sys.stderr)
        return
    try:
        from simulate_dfr_pipeline import (
            parse_circuit, load_perspective_tables, sparse_projection,
            linear_interp, load_persp_recip_paged,
        )
    except ImportError as e:
        print(f"# Impossible d'importer le simulateur : {e}", file=sys.stderr)
        return

    project = Path(__file__).resolve().parent.parent
    horizon, scaling = load_perspective_tables(
        project / 'lotus-ste/doc/extraction/unpacked/FILE59.bin'
    )
    paged = load_persp_recip_paged(project / 'engine/projection/Persp_Recip_paged.bin')

    # Détermine le circuit_id
    circuit_id = circuit_override
    if circuit_id is None and syms:
        # Auto-détecte via le lwmap : cherche tous les Circuit_<id>_segments
        # ET match avec ACTIVE_CIRCUIT_BASE si présent (= addr du circuit actif).
        active_base = syms.get('ACTIVE_CIRCUIT_BASE')
        if active_base is None:
            # Fallback : cherche tous les Circuit_*_segments et prend celui dont
            # l'adresse matche Circuit_base (= variable runtime)
            # Pour l'instant : prend celui qui correspond à l'addr de SP's reads
            import re
            seg_syms = {k: v for k, v in syms.items()
                        if re.match(r'^Circuit_[^_]+(?:_[^_]+)*_segments$', k)}
        else:
            seg_syms = {k: v for k, v in syms.items()
                        if v == active_base and k.endswith('_segments')}
        if seg_syms:
            # Best match : celui dont l'adresse matche les autres clues
            for sym_name in seg_syms:
                if not sym_name.endswith('_segments'):
                    continue
                cid = sym_name[len('Circuit_'):-len('_segments')]
                circuit_path = project / 'engine' / 'circuits' / f'{cid}.asm'
                if circuit_path.exists():
                    circuit_id = cid
                    break

    if circuit_id is None:
        print(f"# Aucun circuit auto-détecté ; spécifier --circuit", file=sys.stderr)
        return

    circuit_path = project / 'engine' / 'circuits' / f'{circuit_id}.asm'
    if not circuit_path.exists():
        print(f"# Circuit ASM introuvable : {circuit_path}", file=sys.stderr)
        return

    print(f"# --compare-sim utilise circuit : {circuit_id}")
    segments = parse_circuit(circuit_path, circuit_id)

    sim_slots, _ = sparse_projection(segments, seg, nibble, horizon, scaling)
    sim_dense = linear_interp(sim_slots, paged)

    rt_slots = frame['sparse_slots']
    rt_dense = frame['dense_triplets']

    print(f"\n=== COMPARE RUNTIME vs SIM (seg={seg} nibble={nibble}) ===")
    print(f"N : runtime={len(rt_slots)} sim={len(sim_slots)}")
    print(f"\nSparse Y trajectory diff (last 16 slots) :")
    n = min(len(rt_slots), len(sim_slots), 16)
    print(f"  idx | RT.Y | SIM.Y | match")
    for i in range(-n, 0):
        rt_y = rt_slots[i]['Y']
        sim_y = sim_slots[i]['slot_Y']
        ok = '✓' if rt_y == sim_y else '✗'
        print(f"  {i:3d} | {rt_y:4d} | {sim_y:5d} | {ok}")

    print(f"\nDense width diff :")
    print(f"  Y   | RT.w | SIM.w | Δ")
    all_y = sorted(set(rt_dense.keys()) | set(sim_dense.keys()))
    match = total = 0
    for y in all_y:
        rt_w = rt_dense.get(y, {}).get('width', '?')
        sim_w = sim_dense.get(y, {}).get('width', '?')
        delta = '?'
        if isinstance(rt_w, int) and isinstance(sim_w, int):
            delta = sim_w - rt_w
            total += 1
            if delta == 0: match += 1
        print(f"  {y:3d} | {rt_w!s:>4} | {sim_w!s:>5} | {delta!s:>4}")
    print(f"\nWidth match : {match}/{total} scanlines")


if __name__ == '__main__':
    main()
