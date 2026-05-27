#!/usr/bin/env python3
"""
Convertit les lignes de route préshiftées Lotus ST → Thomson TO8.

Conversion ST → TO8 :
- ST mode "low" : pixels carrés 320×200 (16 couleurs)
- TO8 mode BM16 : pixels rectangulaires 2:1 → 160×200 (16 couleurs)
  Pour préserver l'aspect ratio visuel, on DIVISE la largeur ST par 2.

Donc chaque sprite préshifté ST (384..768 px de large) devient
TO8 (192..384 px de large), même hauteur (1 ligne).

Méthode de réduction :
- Subsample : on prend 1 pixel sur 2 (pixel pair). Préserve les couleurs
  exactes (pas de moyenne qui mélangerait les indices). Pour les sprites
  pixel-art c'est la meilleure approche.

Source : ../lotus-ste/doc/extraction/road_lines/
    normal_light/000.png ... 254.png
    normal_dark/000.png ... 254.png
    pits_light/000.png ... 254.png
    pits_dark/000.png ... 254.png
    composite_normal_light.png ... composite_pits_dark.png

Destination : ./output/road_lines_to8/
    normal_light/000.png ... 254.png    (largeurs / 2)
    normal_dark/...
    pits_light/...
    pits_dark/...
    composite_*.png                       (largeurs / 2)

Format PNG en sortie :
- Indexé (color_type=3)
- Index 0 inutilisé (= noir par défaut)
- Index 1..16 = couleurs ST 0..15 (identique à la source)
- Palette : copiée depuis la source ST

Usage :
    python3 tools/convert_road_lines.py
    python3 tools/convert_road_lines.py --src PATH --dst PATH
"""

import struct
import sys
import zlib
from pathlib import Path


# ============================================================================
# Lecture/écriture PNG indexé minimal (pas de dépendance externe)
# ============================================================================

def read_png_indexed(path: Path):
    """
    Lit un PNG indexé (color_type=3) et retourne (width, height, pixels_2d, palette).
    pixels_2d : liste de listes d'indices PNG (0..255)
    palette : liste de tuples (r, g, b), index 0..255
    """
    data = path.read_bytes()
    if data[:8] != b'\x89PNG\r\n\x1a\n':
        raise ValueError(f"Pas un PNG : {path}")

    pos = 8
    width = height = depth = ctype = 0
    palette = []
    idat = b''

    while pos < len(data):
        clen = struct.unpack('>I', data[pos:pos + 4])[0]
        tag = data[pos + 4:pos + 8]
        payload = data[pos + 8:pos + 8 + clen]
        pos += 8 + clen + 4   # +4 pour le CRC

        if tag == b'IHDR':
            width, height, depth, ctype = struct.unpack('>IIBB', payload[:10])
            if ctype != 3:
                raise ValueError(f"PNG non paletté (color_type={ctype}) : {path}")
        elif tag == b'PLTE':
            for i in range(0, len(payload), 3):
                palette.append((payload[i], payload[i + 1], payload[i + 2]))
        elif tag == b'IDAT':
            idat += payload
        elif tag == b'IEND':
            break

    raw = zlib.decompress(idat)
    # raw = pour chaque ligne : 1 octet filter + width octets
    pixels_2d = []
    bpp = 1   # 8 bits/pixel
    stride = 1 + width
    for y in range(height):
        line_start = y * stride
        filt = raw[line_start]
        line = raw[line_start + 1:line_start + 1 + width]
        # Pour color_type=3 (palette), filter 0 (None) est le cas standard
        # On gère aussi filter 1 (Sub) au cas où, mais habituellement c'est 0
        if filt == 0:
            pixels_2d.append(list(line))
        elif filt == 1:   # Sub
            cur = bytearray(line)
            for x in range(1, len(cur)):
                cur[x] = (cur[x] + cur[x - 1]) & 0xff
            pixels_2d.append(list(cur))
        else:
            raise ValueError(f"Filter PNG non géré : {filt}")

    while len(palette) < 256:
        palette.append((0, 0, 0))

    return width, height, pixels_2d, palette


def write_png_indexed(path: Path, pixels_2d, palette_rgb_256, transparent_idx_0=True):
    """
    Écrit PNG paletté 8-bit. Si transparent_idx_0=True, ajoute un chunk
    tRNS qui rend l'index 0 entièrement transparent (alpha=0).
    """
    height = len(pixels_2d)
    width = max(len(row) for row in pixels_2d) if pixels_2d else 0
    if width == 0 or height == 0:
        return

    plte = b''.join(struct.pack('BBB', *c) for c in palette_rgb_256[:256])

    raw = bytearray()
    for row in pixels_2d:
        raw.append(0)
        raw.extend(row)
        if len(row) < width:
            raw.extend([0] * (width - len(row)))
    compressed = zlib.compress(bytes(raw), 9)

    def chunk(tag, data):
        crc = zlib.crc32(tag + data)
        return struct.pack('>I', len(data)) + tag + data + struct.pack('>I', crc)

    ihdr = struct.pack('>IIBBBBB', width, height, 8, 3, 0, 0, 0)
    out = b'\x89PNG\r\n\x1a\n'
    out += chunk(b'IHDR', ihdr)
    out += chunk(b'PLTE', plte)
    if transparent_idx_0:
        out += chunk(b'tRNS', bytes([0]))   # alpha=0 pour index 0
    out += chunk(b'IDAT', compressed)
    out += chunk(b'IEND', b'')
    path.write_bytes(out)


# ============================================================================
# Conversion ST → TO8 (réduction largeur 2:1)
# ============================================================================

def subsample_horizontal_2x(pixels_2d):
    """
    Subsample par 2 horizontalement : prend 1 pixel sur 2.
    Préserve les couleurs (pas de moyenne).

    Pour un sprite de N px de large, sortie = N/2 px (arrondi entier).

    On prend les pixels d'indice PAIR (0, 2, 4, ...) — ce qui correspond
    au "centre" de chaque paire et donne un résultat visuel plus stable
    pour les motifs symétriques (route avec stripes centrales).
    """
    out = []
    for row in pixels_2d:
        # Prend 1 pixel sur 2 à partir de l'indice 0
        out.append(row[::2])
    return out


def convert_png(src_path: Path, dst_path: Path):
    """Lit un PNG ST, le subsample par 2 horizontalement, écrit le PNG TO8."""
    width, height, pixels, palette = read_png_indexed(src_path)
    pixels_to8 = subsample_horizontal_2x(pixels)
    dst_path.parent.mkdir(parents=True, exist_ok=True)
    write_png_indexed(dst_path, pixels_to8, palette)
    return width, height, len(pixels_to8[0]) if pixels_to8 else 0, len(pixels_to8)


# ============================================================================
# Main
# ============================================================================

VARIANTS = ['normal_light', 'normal_dark', 'pits_light', 'pits_dark']


def main(argv):
    # Chemins par défaut RELATIFS au script (= tools/), pas au cwd
    script_dir = Path(__file__).resolve().parent
    src_root = script_dir.parent / 'lotus-ste' / 'doc' / 'extraction' / 'road_lines'
    dst_root = script_dir / 'output' / 'road_lines_to8'

    # Parse args optionnels
    args = list(argv[1:])
    if '--src' in args:
        idx = args.index('--src')
        src_root = Path(args[idx + 1]).resolve()
        args.pop(idx + 1); args.pop(idx)
    if '--dst' in args:
        idx = args.index('--dst')
        dst_root = Path(args[idx + 1]).resolve()
        args.pop(idx + 1); args.pop(idx)

    if not src_root.exists():
        print(f"❌ Source road_lines introuvable : {src_root}", file=sys.stderr)
        return 1

    print(f"📂 Source : {src_root}")
    print(f"📂 Destination : {dst_root}")
    dst_root.mkdir(parents=True, exist_ok=True)

    total_ok = 0
    total_err = 0

    # Une PNG rectangulaire par variant : {variant}.png (largeur ST 768 → TO8 384)
    for variant in VARIANTS:
        src_png = src_root / f"{variant}.png"
        dst_png = dst_root / f"{variant}.png"
        if not src_png.exists():
            print(f"⚠️  Pas de PNG : {src_png}")
            total_err += 1
            continue
        try:
            src_w, src_h, dst_w, dst_h = convert_png(src_png, dst_png)
            print(f"   {variant}.png : {src_w}×{src_h} → {dst_w}×{dst_h}")
            total_ok += 1
        except Exception as e:
            print(f"   ERR {variant}: {e}")
            total_err += 1

    print(f"\n✓ Total : {total_ok} fichiers convertis, {total_err} erreurs")
    return 0 if total_err == 0 else 2


if __name__ == '__main__':
    sys.exit(main(sys.argv))
