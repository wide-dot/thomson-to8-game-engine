#!/usr/bin/env python3
"""
render_road_frame.py — Rasterise une frame route en PNG, pour comparaison VISUELLE.

  --from-trace : reconstruit la VRAM réellement écrite par DrawFrameRoad (décode
                 les PSHU). Capture BORNÉE à l'exécution de DrawFrameRoad (pile),
                 donc s'arrête avant DrawSprites (= pas la voiture). VÉRITÉ-TERRAIN.
  --from-sim   : rejoue SP→LI→modèle leftEdge en Python ET dessine les VRAIS
                 pixels route en décodant les chunks Road_R* (D,X) des patterns
                 + buffers réels, positionnés par le modèle leftEdge.

Encodage BM16 (cf road_common.pixels_to_bm16, inversé ici) :
  4 px = 1 octet RAMA (p0<<4|p1) + 1 octet RAMB (p2<<4|p3). couleur = index PNG-1.
  Bank RAMB=$A000, RAMA=$C000. 40 oct/ligne/bank.
Chunk Road_R* = ldd #D ; ldx #X ; pshu d,x → 4 octets [D_hi,D_lo,X_hi,X_lo].
Herbe = $2222/$2222 (index couleur 2).

Usage :
  python3 tools/render_road_frame.py --from-trace dist/dcmoto_trace.txt --out trace.png
  python3 tools/render_road_frame.py --from-sim 22_hard_5 130 8 -192 --out sim.png
  python3 tools/render_road_frame.py --from-trace ... --from-sim ... --out compare.png
"""

import argparse
import struct
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from PIL import Image
from lwmap import load_lwmap, find_default_map
from dcmoto_trace import iter_lines

VRAM_RAMB = 0xA000
VRAM_RAMA = 0xC000
LINE_BYTES = 40
SCREEN_W = 160
PATTERNS_ORG = 0x4000
GRASS_CHUNK = (0x22, 0x22, 0x22, 0x22)   # herbe = index couleur 2


# ───────────────────────── palette (PLTE du PNG source) ─────────────────────────

def color_palette(png_path):
    data = Path(png_path).read_bytes()
    pos, plte = 8, [(255, 0, 255)] * 256
    while pos < len(data):
        clen = struct.unpack('>I', data[pos:pos+4])[0]
        tag = data[pos+4:pos+8]
        payload = data[pos+8:pos+8+clen]
        pos += 8 + clen + 4
        if tag == b'PLTE':
            for i in range(clen // 3):
                plte[i] = (payload[i*3], payload[i*3+1], payload[i*3+2])
        elif tag == b'IEND':
            break
    return [plte[c + 1] for c in range(16)]   # BM16 index c → PNG index c+1


# ───────────────────────── VRAM depuis trace (bornée à DrawFrameRoad) ────────────

def decode_pshu(tl):
    """[(addr,byte)] écrits par un PSHU. U post = adresse la plus basse."""
    regs = set(tl.operand.upper().replace(' ', '').split(','))
    order = []
    if 'CC' in regs:               order.append(tl.cc & 0xFF)
    if 'A' in regs or 'D' in regs: order.append((tl.d >> 8) & 0xFF)
    if 'B' in regs or 'D' in regs: order.append(tl.d & 0xFF)
    if 'DP' in regs:               order.append(tl.dp & 0xFF)
    if 'X' in regs:                order += [(tl.x >> 8) & 0xFF, tl.x & 0xFF]
    if 'Y' in regs:                order += [(tl.y >> 8) & 0xFF, tl.y & 0xFF]
    return [((tl.u + i) & 0xFFFF, v) for i, v in enumerate(order)]


def _in_vram(a):
    return VRAM_RAMB <= a < VRAM_RAMB + 0x2000 or VRAM_RAMA <= a < VRAM_RAMA + 0x2000


def reconstruct_vram_from_trace(trace, syms):
    """Capture les écritures VRAM PENDANT DrawFrameRoad uniquement (profondeur
       de pile : on s'arrête au rts qui ramène depth à 0, donc avant DrawSprites)."""
    dfr = syms['DrawFrameRoad']
    vram = {}
    started = False
    depth = 0
    for tl in iter_lines(trace):
        if not started:
            if tl.pc == dfr:
                started, depth = True, 1
            else:
                continue
        # capture
        if tl.mnem == 'PSHU':
            for a, v in decode_pshu(tl):
                if _in_vram(a):
                    vram[a] = v
        elif tl.mnem in ('STD', 'STX', 'STY', 'STU') and tl.operand.startswith('$'):
            try:
                a = int(tl.operand[1:], 16)
            except ValueError:
                a = None
            if a is not None:
                val = {'STD': tl.d, 'STX': tl.x, 'STY': tl.y, 'STU': tl.u}[tl.mnem]
                for off, b in ((0, (val >> 8) & 0xFF), (1, val & 0xFF)):
                    if _in_vram(a + off):
                        vram[a + off] = b
        # profondeur de pile
        m = tl.mnem
        if m in ('JSR', 'BSR', 'LBSR'):
            depth += 1
        elif m == 'RTS' or (m == 'PULS' and 'PC' in tl.operand.upper()):
            depth -= 1
            if depth <= 0:
                break
    return vram


def render_vram(vram, palette, y0, y1):
    img = Image.new('RGB', (SCREEN_W, y1 - y0), (255, 0, 255))  # magenta = non écrit par DFR
    px = img.load()
    for y in range(y0, y1):
        ra_base, rb_base = VRAM_RAMA + y * LINE_BYTES, VRAM_RAMB + y * LINE_BYTES
        for k in range(LINE_BYTES):
            ra, rb = vram.get(ra_base + k), vram.get(rb_base + k)
            for i, c in enumerate((
                (ra >> 4) & 0xF if ra is not None else None,
                ra & 0xF if ra is not None else None,
                (rb >> 4) & 0xF if rb is not None else None,
                rb & 0xF if rb is not None else None,
            )):
                x = 4 * k + i
                if c is not None and x < SCREEN_W:
                    px[x, y - y0] = palette[c]
    return img


# ───────────────────────── SIM : vrais pixels via buffers + patterns ─────────────

def read_line_buffer(buf, off):
    """Header (M, 1 oct) + M adresses de chunks Road_R* (fdb).
       K/J ne sont plus stockés (recalculés au runtime depuis leftEdge)."""
    M = buf[off]
    core = [(buf[off+1+2*i] << 8) | buf[off+1+2*i+1] for i in range(M)]
    return M, core


def _signed16(v):
    v &= 0xFFFF
    return v - 0x10000 if v & 0x8000 else v


def _signed_shr4(v):
    """asr #4 signé (floor /16) sur 16 bits."""
    if v >= 0:
        return v >> 4
    return _signed16(((v & 0xFFFF) >> 4) | 0xF000)


def render_road_from_dense(dense, lateral_scaled, y0, y1, palette, root):
    """Cœur du rendu : applique le MÊME modèle leftEdge que DrawFrameRoad.asm
       à un dict dense {Y: {flags, width}}, en dessinant les vrais chunks.
       `dense` peut venir du simulateur (SP→LI) OU de la trace (1:1)."""
    from oracle_road_position import load_line_offsets, load_lines_table
    line_off = load_line_offsets(root/'game-mode/road/generated/road_buffers_externs.inc')
    lines_tab = load_lines_table(root/'game-mode/road/generated/road_lines_table.asm')
    buf = (root/'objects/road-buffers/generated/road_buffers.bin').read_bytes()
    pat = (root/'game-mode/road/generated/road_patterns_dark.bin').read_bytes()
    # CENTER = $90/2 = 72 (fidèle Lotus : 68k centre route à $90=144 sur 320px).
    CENTER = 72

    def chunk(addr):
        a = addr - PATTERNS_ORG
        if 0 <= a and a + 5 < len(pat):
            return (pat[a+1], pat[a+2], pat[a+4], pat[a+5])
        return GRASS_CHUNK

    img = Image.new('RGB', (SCREEN_W, y1 - y0), (0, 0, 0))
    px = img.load()
    for y, t in dense.items():
        if not (y0 <= y < y1):
            continue
        width = t['width']
        slot_x = _signed16((t['flags'] & 0xFFFF) & 0xFFFC)   # slot.X (bits 0-1 strip)
        combined = _signed16(slot_x + lateral_scaled)
        product = _signed16((combined * width) >> 16)
        neg_product = _signed16(-product)
        li = min(254, width >> 4)
        if li >= len(lines_tab):
            continue
        M, rama_core = read_line_buffer(buf, line_off[lines_tab[li][0]])  # RAMA_s0
        _, ramb_core = read_line_buffer(buf, line_off[lines_tab[li][2]])  # RAMB_s0
        # === Position FIDÈLE 68k FUN_0007661e ===
        #   leftEdge = centerX - demi-largeur, demi-largeur = width>>5 CONTINUE
        #   (68k : lsr #4 sur width ST = width>>5 en TO8), centre $90/2 = 72.
        #   ⇒ leftEdge lisse (vs M*8 quantifié qui sautait ±8px sur les pas de M).
        #   La LARGEUR dessinée reste M chunks (contenu pré-rendu du buffer).
        leftEdge = (CENTER + neg_product) - (width >> 5)
        LE = _signed_shr4(leftEdge)
        sub = leftEdge & 0x0F
        right = LE + M
        Jp = max(0, min(10, LE))
        vis_end = max(0, min(10, right))
        F = vis_end - Jp
        coreOff = max(0, right - 10)
        row = [2] * SCREEN_W   # défaut herbe (index 2)
        for w in range(10):
            if Jp <= w < Jp + F:
                ci = coreOff + (F - 1) - (w - Jp)   # leftmost visible = core[coreOff+F-1]
                rc = chunk(rama_core[ci]) if 0 <= ci < len(rama_core) else GRASS_CHUNK
                bc = chunk(ramb_core[ci]) if 0 <= ci < len(ramb_core) else GRASS_CHUNK
            else:
                rc = bc = GRASS_CHUNK
            for j in range(4):
                b = w * 16 + 4 * j
                row[b+0] = (rc[j] >> 4) & 0xF
                row[b+1] = rc[j] & 0xF
                row[b+2] = (bc[j] >> 4) & 0xF
                row[b+3] = bc[j] & 0xF
        for x in range(SCREEN_W):
            sx = x + sub
            if 0 <= sx < SCREEN_W:
                px[sx, y - y0] = palette[row[x]]
    return img


def render_road_continuous(dense, lateral_scaled, y0, y1, palette, root):
    """RÉFÉRENCE 68k : bords leftEdge/rightEdge CONTINUS (pas de chunks M figés).
       grass | rumble@leftEdge | asphalte | rumble@rightEdge | grass. Lisse par
       construction → cible correcte à atteindre (vs le port chunk-quantifié)."""
    GREEN, ASPH_D, ASPH_L, RED, WHITE = (40,108,40), (96,96,96), (170,170,170), (200,40,40), (235,235,235)
    CENTER = 72
    RUMBLE = 3   # px largeur rumble
    img = Image.new('RGB', (SCREEN_W, y1 - y0), GREEN)
    px = img.load()
    for y, t in dense.items():
        if not (y0 <= y < y1):
            continue
        width = t['width']
        slot_x = _signed16((t['flags'] & 0xFFFF) & 0xFFFC)
        combined = _signed16(slot_x + lateral_scaled)
        neg = _signed16(-_signed16((combined * width) >> 16))
        half = width >> 5
        center = CENTER + neg
        left = center - half
        right = center + half
        asph = ASPH_L if ((t.get('extra', 0) >> 10) & 1) else ASPH_D   # dither dark/light
        row = y - y0
        for x in range(SCREEN_W):
            if x < left or x >= right:
                continue                       # herbe (fond)
            if x < left + RUMBLE or x >= right - RUMBLE:
                px[x, row] = RED               # rumble bords continus
            elif abs(x - center) < 1:
                px[x, row] = WHITE             # ligne centrale
            else:
                px[x, row] = asph
    return img


def render_ref_real(dense, lateral_scaled, y0, y1, root, phase=0, full_line=False, bg_color=None, tex_dir=None, palette=None):
    """RÉFÉRENCE 68k avec VRAIE texture Lotus : prend la ligne route source
       (normal_dark/light.png), la met à l'échelle de la largeur écran CONTINUE,
       centrée à centerX = $90/2 - product, et alterne dark/light par scanline
       (bit 10). = cible visuelle originale (bords lisses + vrai motif).
       full_line : si True, dessine la ligne ENTIÈRE (herbe idx3/4 comprise =
       extent non-transparent) -> l'herbe alterne dark/light comme la route.
       bg_color : couleur de fond (zone non dessinée par l'algo route). Défaut=herbe."""
    import struct
    from road_common import read_png_indexed, measure_effective_width

    def load_png(p):
        w, h, px = read_png_indexed(p)
        d = p.read_bytes(); pos = 8; plte = [(255, 0, 255)] * 256
        while pos < len(d):
            clen = struct.unpack('>I', d[pos:pos+4])[0]; tag = d[pos+4:pos+8]
            pay = d[pos+8:pos+8+clen]; pos += 12 + clen
            if tag == b'PLTE':
                for i in range(clen // 3):
                    plte[i] = (pay[i*3], pay[i*3+1], pay[i*3+2])
            elif tag == b'IEND':
                break
        return w, h, px, plte

    src = Path(tex_dir) if tex_dir else root / 'tools' / 'road_sprites_source'
    wd, hd, dark, plte = load_png(src / 'normal_dark.png')
    _,  _,  light, _   = load_png(src / 'normal_light.png')
    # ROAD = rumble-à-rumble (ancre [left,right]) ; FULL = non-transparent (herbe
    # idx3/4 comprise). full_line : on dessine FULL à l'ÉCHELLE de la route (la route
    # garde sa taille normale dans [left,right], l'herbe s'étend AU-DELÀ à la même
    # échelle). -> l'herbe alterne dark/light comme la route.
    ROAD_IDX = (1, 2, 5, 6, 7)
    def span_of(row, idxs):
        xs = [x for x in range(len(row)) if (row[x] != 0 if idxs is None else row[x] in idxs)]
        return (min(xs), max(xs) + 1) if xs else (0, 0)
    road_spans = [span_of(dark[y], ROAD_IDX) for y in range(hd)]
    full_spans = [span_of(dark[y], None) for y in range(hd)]
    bg = bg_color if bg_color is not None else plte[4]
    img = Image.new('RGB', (SCREEN_W, y1 - y0), bg)
    px = img.load()
    for y, t in dense.items():
        if not (y0 <= y < y1):
            continue
        width = t['width']
        slot_x = _signed16((t['flags'] & 0xFFFF) & 0xFFFC)
        neg = _signed16(-_signed16((_signed16(slot_x + lateral_scaled) * width) >> 16))
        half = width >> 5
        center = 72 + neg
        left, right = center - half, center + half
        if right <= left:
            continue
        li = min(hd - 1, width >> 4)
        # dark/light = bit 10 de (extra + phase), CONFORME DrawFrameRoad : la phase
        # live (= track_pos.lower>>4 & $7FF) fait DÉFILER les bandes même géométrie figée.
        row = light[li] if ((t.get('extra', 0) + phase) & 0x400) else dark[li]
        rs, re = road_spans[li]
        if re <= rs:
            continue
        if full_line:
            # échelle = route mappée sur [left,right] ; on étend FULL à cette échelle
            k = (right - left) / (re - rs)
            fs, fe = full_spans[li]
            s = fs
            ew = fe - fs
            scr_lo = left - (rs - fs) * k       # bord gauche écran de l'herbe
            scr_w = (fe - fs) * k               # largeur écran totale de la ligne
        else:
            s = rs
            ew = re - rs
            scr_lo = left
            scr_w = right - left
        if ew <= 0 or scr_w <= 0:
            continue
        rown = y - y0
        x0 = max(0, int(scr_lo))
        x1 = min(SCREEN_W, int(scr_lo + scr_w) + 1)
        for x in range(x0, x1):
            srcx = s + int((x - scr_lo) / scr_w * ew)
            idx = row[min(max(srcx, 0), len(row) - 1)]
            if idx != 0:                       # 0 = transparent → reste fond
                # palette par INDEX (idx texture 1..16 -> palette[idx-1]) si fournie,
                # sinon palette native de la texture.
                if palette is not None and 0 < idx <= len(palette):
                    px[x, rown] = palette[idx - 1]
                else:
                    px[x, rown] = plte[idx]
    return img


def render_sim_real(circuit, seg, nibble, lateral, y0, y1, palette, root):
    """SIM autonome : SP→LI depuis circuit/seg/nibble, puis modèle leftEdge."""
    from simulate_dfr_pipeline import (
        parse_circuit, load_perspective_tables, sparse_projection,
        linear_interp, load_persp_recip_paged,
    )
    segs = parse_circuit(root/'engine'/'circuits'/f'{circuit}.asm', circuit)
    horizon, scaling = load_perspective_tables(root/'lotus-ste/doc/extraction/unpacked/FILE59.bin')
    paged = load_persp_recip_paged(root/'engine/projection/Persp_Recip_paged.bin')
    slots, _ = sparse_projection(segs, seg, nibble, horizon, scaling)
    dense = linear_interp(slots, paged)
    return render_road_from_dense(dense, _signed16(lateral * 8), y0, y1, palette, root)


def extract_lateral_scaled_from_trace(trace, syms):
    """Lit la valeur écrite à DFR_lateral_scaled pendant la frame (STD)."""
    addr = syms.get('DFR_lateral_scaled')
    op = f'${addr:04X}' if addr else None
    for tl in iter_lines(trace):
        if tl.mnem == 'STD' and tl.operand == op:
            return _signed16(tl.d)
    return 0


def render_sim_from_trace(trace, syms, y0, y1, palette, root):
    """1:1 : utilise le dense + la latérale RÉELS de la trace, rendu par le modèle.
       Doit être quasi identique au rendu --from-trace si le runtime = le modèle."""
    from extract_road_state import iter_frames
    frame = next(iter_frames(trace, syms, max_frames=1))
    dense = {y: {'flags': t['flags'], 'width': t['width']}
             for y, t in frame['dense_triplets'].items()}
    lat = extract_lateral_scaled_from_trace(trace, syms)
    print(f"# 1:1 dense trace : {len(dense)} scanlines, lateral_scaled={lat}")
    return render_road_from_dense(dense, lat, y0, y1, palette, root)


def render_ref_from_trace(trace, syms, y0, y1, palette, root):
    """RÉFÉRENCE 68k continue, sur le dense+latérale réels de la trace."""
    from extract_road_state import iter_frames
    frame = next(iter_frames(trace, syms, max_frames=1))
    dense = {y: {'flags': t['flags'], 'width': t['width'], 'extra': t['extra']}
             for y, t in frame['dense_triplets'].items()}
    lat = extract_lateral_scaled_from_trace(trace, syms)
    return render_ref_real(dense, lat, y0, y1, root)


# ───────────────────────── CLI ─────────────────────────

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--from-trace', metavar='TRACE')
    ap.add_argument('--from-sim', nargs=4, metavar=('CIRCUIT', 'SEG', 'NIBBLE', 'LATERAL'))
    ap.add_argument('--sim-from-trace', metavar='TRACE',
                    help='1:1 — rejoue le modèle leftEdge sur le dense+latérale RÉELS de la trace')
    ap.add_argument('--ref-from-trace', metavar='TRACE',
                    help='RÉFÉRENCE 68k : bords continus (cible correcte) sur le dense de la trace')
    ap.add_argument('--map', default=None)
    ap.add_argument('--png', default=None)
    ap.add_argument('--y0', type=int, default=38)
    ap.add_argument('--y1', type=int, default=100)
    ap.add_argument('--scale', type=int, default=5)
    ap.add_argument('--out', required=True)
    args = ap.parse_args()

    root = Path(__file__).resolve().parent.parent
    png = args.png or str(root / 'tools' / 'road_sprites_source' / 'normal_dark.png')
    palette = color_palette(png)

    imgs, labels = [], []
    if args.from_trace:
        syms = load_lwmap(args.map or find_default_map())
        vram = reconstruct_vram_from_trace(args.from_trace, syms)
        print(f"# VRAM (DrawFrameRoad only) : {len(vram)} octets")
        imgs.append(render_vram(vram, palette, args.y0, args.y1)); labels.append('TRACE')
    if args.from_sim:
        c, s, n, l = args.from_sim[0], int(args.from_sim[1]), int(args.from_sim[2]), int(args.from_sim[3])
        imgs.append(render_sim_real(c, s, n, l, args.y0, args.y1, palette, root)); labels.append('SIM')
    if args.sim_from_trace:
        syms = load_lwmap(args.map or find_default_map())
        imgs.append(render_sim_from_trace(args.sim_from_trace, syms, args.y0, args.y1, palette, root))
        labels.append('SIM (1:1 dense trace)')
    if args.ref_from_trace:
        syms = load_lwmap(args.map or find_default_map())
        imgs.append(render_ref_from_trace(args.ref_from_trace, syms, args.y0, args.y1, palette, root))
        labels.append('REF 68k (bords continus)')

    if not imgs:
        print("Spécifier --from-trace et/ou --from-sim", file=sys.stderr); sys.exit(1)

    gap = 8
    W = sum(i.width for i in imgs) + gap * (len(imgs) - 1)
    H = max(i.height for i in imgs)
    canvas = Image.new('RGB', (W, H), (40, 40, 40))
    x = 0
    for i in imgs:
        canvas.paste(i, (x, 0)); x += i.width + gap
    canvas.resize((W * args.scale, H * args.scale), Image.NEAREST).save(args.out)
    print(f"✓ {args.out}  [{' | '.join(labels)}]")


if __name__ == '__main__':
    main()
