#!/usr/bin/env python3
"""
extract_road_draw_position.py — Position route RÉELLE depuis la trace runtime.

Lève toutes les hypothèses du modèle Python : on lit ce que DrawFrameRoad
DESSINE VRAIMENT. Pour chaque scanline, on capture au `jsr ,X` du
DFR_dispatch_and_draw :
  - U  = curseur VRAM effectif (= inclut byte_offset / rama_bank_off)
  - X  = routine Road_draw_K{K'}_J{J'} appelée → (K', J') exacts

De là on reconstruit la position écran réelle de la route :
  Layout BM16 : 40 oct/scanline, 1 oct = 4 px, 1 chunk = 4 oct = 16 px.
  Bloc dessiné = [U-40, U-1]. Convention "-2 cheval bordure".
  Sur l'écran, gauche→droite : [J' herbe][F route][K' herbe]  (F = 10-K'-J')
  → road_left_col_byte = (U - 40 - base) - Y*40 + J'*4

On compare à la RÉFÉRENCE 68k calculée depuis le MÊME triplet dense de la
trace (slotX, width) : centerX = CENTER - product ; leftEdge = centerX - demi.

Usage :
    # lister les frames + amplitude (pour repérer une frame qui bouge)
    python3 tools/extract_road_draw_position.py --trace dist/dcmoto_trace.txt --scan

    # détail d'une frame
    python3 tools/extract_road_draw_position.py --trace dist/dcmoto_trace.txt --frame 7
"""

import argparse
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from lwmap import load_lwmap, find_default_map
from dcmoto_trace import iter_lines
from extract_road_state import iter_frames
from oracle_road_position import ref_68k


def build_road_draw_map(syms):
    """addr → (K',J') depuis les symboles Road_draw_K{k}_J{j}."""
    pat = re.compile(r'^Road_draw_K(\d+)_J(\d+)$')
    m = {}
    for name, addr in syms.items():
        mm = pat.match(name)
        if mm:
            m[addr] = (int(mm.group(1)), int(mm.group(2)))
    return m


def capture_dispatches(trace_path, dfr_entry_line, sp_addr, disp_lo, disp_hi, road_draw_map):
    """Scanne le range DFR d'une frame ; capture (U, K', J') à chaque jsr ,X.

    Retourne list de dicts {U, Kp, Jp, bank, Y}.
    """
    caps = []
    started = False
    for tl in iter_lines(trace_path, line_range=(dfr_entry_line, None)):
        if tl.pc == sp_addr:        # début frame suivante → stop
            break
        # jsr ,X dans DFR_dispatch_and_draw : PC dans [disp_lo, disp_hi], mnem JSR
        if disp_lo <= tl.pc < disp_hi and tl.mnem == 'JSR':
            target = tl.x
            if target in road_draw_map:
                U = tl.u
                base = 0xA000 if U < 0xC000 else 0xC000
                bank = 'RAMB' if base == 0xA000 else 'RAMA'
                Y = ((U - base + 2) // 40) - 1
                Kp, Jp = road_draw_map[target]
                caps.append({'U': U, 'Kp': Kp, 'Jp': Jp, 'bank': bank, 'Y': Y})
    return caps


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--trace', required=True)
    ap.add_argument('--map', default=None)
    ap.add_argument('--frame', type=int, default=None, help='1-based')
    ap.add_argument('--scan', action='store_true', help='liste frames + amplitude slotX')
    ap.add_argument('--max-frames', type=int, default=None)
    ap.add_argument('--lat-scaled', type=int, default=0,
                    help='lateral_scaled runtime (= lateral_pos*8) à injecter dans la réf 68k. '
                         'Lire la valeur STD DFR_lateral_scaled dans la trace (ex: $FA00=-1536).')
    args = ap.parse_args()

    syms = load_lwmap(args.map or find_default_map())
    sp_addr = syms['SparseProjection']
    disp_lo = syms['DFR_dispatch_and_draw']
    disp_hi = syms['DFR_dispatch_skip']
    road_draw_map = build_road_draw_map(syms)
    print(f"# {len(road_draw_map)} routines Road_draw mappées ; dispatch [{disp_lo:04X},{disp_hi:04X})")

    if args.scan:
        print("  frame | n_dense | slotX[min..max] | width[min..max]")
        for i, fr in enumerate(iter_frames(args.trace, syms, max_frames=args.max_frames), 1):
            tr = fr['dense_triplets']
            if not tr:
                continue
            xs = [(t['flags'] & 0xFFFF) & 0xFFFC for t in tr.values()]
            xs = [x - 0x10000 if x & 0x8000 else x for x in xs]
            ws = [t['width'] for t in tr.values()]
            print(f"  {i:5d} | {len(tr):7d} | {min(xs):+6d}..{max(xs):+6d} | {min(ws):5d}..{max(ws):5d}")
        return

    if args.frame is None:
        print("Spécifier --frame N ou --scan", file=sys.stderr)
        sys.exit(1)

    # Récupère la frame (dense + ligne d'entrée DFR)
    target = None
    for i, fr in enumerate(iter_frames(args.trace, syms, max_frames=args.frame), 1):
        if i == args.frame:
            target = fr
            break
    if target is None:
        print(f"Frame {args.frame} introuvable", file=sys.stderr)
        sys.exit(1)

    dense = target['dense_triplets']
    dfr_entry = target['dfr_call'][0] if target['dfr_call'] else None
    if dfr_entry is None:
        print("Pas d'appel DFR dans cette frame", file=sys.stderr)
        sys.exit(1)

    caps = capture_dispatches(args.trace, dfr_entry, sp_addr, disp_lo, disp_hi, road_draw_map)
    # garde la passe RAMB (1 par scanline ; RAMA redondant pour la position)
    by_y = {}
    for c in caps:
        if c['bank'] == 'RAMB':
            by_y[c['Y']] = c

    print(f"\n=== FRAME {args.frame} : position route RÉELLE (trace) vs réf 68k ===")
    print(f"    {len(by_y)} scanlines dessinées (RAMB)\n")
    print("  Y  | width| slotX |K' F J'| U_RAMB | PORT[L..R]px | 68k[L..R]px | ΔL  | saut?")
    print("  ---+------+-------+-------+--------+--------------+-------------+-----+------")

    prev_portL = None
    jumps = []
    rows = []
    for Y in sorted(by_y):
        c = by_y[Y]
        U, Kp, Jp = c['U'], c['Kp'], c['Jp']
        F = 10 - Kp - Jp
        base = 0xA000
        # position écran réelle (px) du bord gauche de la route
        road_left_col_byte = (U - 40 - base) - Y * 40 + Jp * 4
        portL = road_left_col_byte * 4
        portR = portL + F * 16

        # réf 68k depuis le triplet dense de CETTE scanline
        t = dense.get(Y)
        if t is None:
            # parfois Y dérivé ±1 ; tente voisins
            t = dense.get(Y + 1) or dense.get(Y - 1)
        if t is not None:
            slotx = (t['flags'] & 0xFFFF) & 0xFFFC
            if slotx & 0x8000:
                slotx -= 0x10000
            width = t['width']
            r = ref_68k(slotx, width, args.lat_scaled)
            refL = r['leftEdge']
            refR = r['leftEdge'] + (r['half_to8'] * 2)
        else:
            slotx = width = refL = refR = None

        dL = (portL - refL) if refL is not None else None
        jump = ''
        if prev_portL is not None and abs(portL - prev_portL) >= 16:
            jump = f'+{portL - prev_portL:d}' if portL > prev_portL else f'{portL - prev_portL:d}'
            jumps.append((Y, portL - prev_portL))
        prev_portL = portL

        sx = f"{slotx:+5d}" if slotx is not None else "    ?"
        wv = f"{width:4d}" if width is not None else "   ?"
        rL = f"{refL:+4d}" if refL is not None else "   ?"
        rR = f"{refR:+4d}" if refR is not None else "   ?"
        dLs = f"{dL:+4d}" if dL is not None else "   ?"
        print(f"  {Y:3d}| {wv} | {sx} | {Kp:2d}{F:2d}{Jp:2d} | ${U:04X} | {portL:+5d}..{portR:+5d} |"
              f" {rL}..{rR} | {dLs} | {jump}")
        rows.append((Y, portL, refL))

    print(f"\n=== SYNTHÈSE ===")
    print(f"  Sauts PORT ≥16px entre scanlines adjacentes : {len(jumps)}")
    for Y, dj in jumps:
        print(f"      Y={Y}: ΔportL={dj:+d}px")
    if rows and all(r[2] is not None for r in rows):
        # cohérence de forme : le PORT suit-il la pente du 68k ?
        dport = sum(abs(rows[i][1]-rows[i-1][1]) for i in range(1, len(rows)))
        dref = sum(abs(rows[i][2]-rows[i-1][2]) for i in range(1, len(rows)))
        print(f"  Variation totale bord gauche : PORT={dport}px  vs  68k={dref}px")
        print(f"  (un PORT bien plus 'agité' que le 68k = jitter = bug visuel)")


if __name__ == '__main__':
    main()
