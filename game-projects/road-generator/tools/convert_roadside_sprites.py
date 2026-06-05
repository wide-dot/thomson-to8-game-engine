#!/usr/bin/env python3
"""
convert_roadside_sprites.py — convertit les PNG sprites bord-de-piste Lotus
(extraits par extract_sprites.py, indexés 0..14 couleurs + 15 transparent,
palette placeholder) vers des PNG prêts pour le builder Bento8 (mode road) :

  - REMAPPE les index couleur du sprite -> index palette ROUTE (mapping
    configurable JSON), pour que la couleur soit cohérente avec le game-mode.
  - EMBARQUE la palette du game-mode (lue à chaque conversion depuis
    game-mode/road/palette/default.png) dans le PNG de sortie -> preview réaliste.
  - Conserve la transparence (index source 15 -> index transparent route via tRNS).
  - SORT directement dans objects/roadside/image/ (déclarables sprite.* Bento8).

Sans dépendance Pillow (lit via road_common.read_png_indexed, écrit un PNG
indexé color_type=3 maison). Mapping par défaut = identité (idx N -> N).

Usage:
  python3 tools/convert_roadside_sprites.py [--map roadside_palette_map.json]
        [--levels 0,2,4,6,8,10,12,16] [--sprites 80,81,82,83,87,8F,90]
        [--src lotus-ste/doc/extraction/sprites_png_v2]
        [--out objects/roadside/image]
"""
import sys, struct, zlib, json, argparse
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from road_common import read_png_indexed   # (w,h,pixels2d) indices 0..255

ROOT = Path(__file__).resolve().parent.parent
DEFAULT_PALETTE = ROOT / "game-mode/road/palette/default.png"
SRC_TRANSPARENT = 15          # convention extract_sprites.py : idx 15 = transparent


def read_palette_rgb(path: Path, n=16):
    """Lit les n premières couleurs du chunk PLTE d'un PNG indexé -> list[(r,g,b)]."""
    data = path.read_bytes()
    i = 8
    while i < len(data):
        ln = struct.unpack('>I', data[i:i+4])[0]
        typ = data[i+4:i+8]
        if typ == b'PLTE':
            ch = data[i+8:i+8+ln]
            return [(ch[k*3], ch[k*3+1], ch[k*3+2]) for k in range(min(n, ln//3))]
        i += 12 + ln
    raise ValueError(f"Pas de PLTE dans {path}")


def write_png_indexed(path: Path, w, h, pixels2d, palette_rgb, transparent_idx):
    """Écrit un PNG indexé color_type=3 + PLTE + tRNS (alpha=0 pour transparent_idx)."""
    def chunk(tag, payload):
        c = tag + payload
        return struct.pack('>I', len(payload)) + c + struct.pack('>I', zlib.crc32(c) & 0xffffffff)
    ihdr = struct.pack('>IIBBBBB', w, h, 8, 3, 0, 0, 0)
    plte = b''.join(struct.pack('BBB', *c) for c in palette_rgb)
    # tRNS : alpha par index, opaque (255) partout sauf transparent_idx (0)
    trns = bytes(0 if k == transparent_idx else 255 for k in range(len(palette_rgb)))
    raw = bytearray()
    for row in pixels2d:
        raw.append(0)                      # filter 0
        raw.extend(row)
    idat = zlib.compress(bytes(raw), 9)
    out = b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', ihdr) + chunk(b'PLTE', plte) \
        + chunk(b'tRNS', trns) + chunk(b'IDAT', idat) + chunk(b'IEND', b'')
    path.write_bytes(out)


def main(argv):
    ap = argparse.ArgumentParser()
    ap.add_argument('--map', default=None, help='JSON mapping {src_idx: road_idx}')
    ap.add_argument('--levels', default='0,2,4,6,8,10,12,16')
    ap.add_argument('--sprites', default='80,81,82,83,87,8F,90')
    ap.add_argument('--src', default='lotus-ste/doc/extraction/sprites_png_v2')
    ap.add_argument('--out', default='objects/roadside/image')
    ap.add_argument('--palette', default=str(DEFAULT_PALETTE))
    ap.add_argument('--transparent', type=int, default=0,
                    help='index palette route utilisé comme transparent (def 0)')
    ap.add_argument('--xdiv', type=int, default=2,
                    help='facteur de réduction horizontale (BM16 160px = ST/2, def 2)')
    a = ap.parse_args(argv)

    # mapping idx source couleur -> idx palette route (identité par défaut)
    pmap = {k: k for k in range(15)}
    if a.map and Path(a.map).exists():
        cfg = json.loads(Path(a.map).read_text())
        for k, v in cfg.get('index_map', {}).items():
            pmap[int(k)] = int(v)
    pmap[SRC_TRANSPARENT] = a.transparent     # 15 -> index transparent route

    palette = read_palette_rgb(Path(a.palette), 16)
    print(f"Palette route ({len(palette)} couleurs) lue depuis {a.palette}")
    levels = [int(x) for x in a.levels.split(',')]
    sprites = a.sprites.split(',')
    outdir = ROOT / a.out
    outdir.mkdir(parents=True, exist_ok=True)
    srcroot = ROOT / a.src

    n = 0
    for sid in sprites:
        fdir = srcroot / f"FILE{sid.upper()}"
        if not fdir.exists():
            print(f"  ! {fdir} absent, skip sprite {sid}")
            continue
        for li, lvl in enumerate(levels):
            src = fdir / f"FILE{sid.upper()}_sub{lvl:02d}.png"
            if not src.exists():
                print(f"  ! {src.name} absent")
                continue
            w, h, px = read_png_indexed(src)
            remapped = [[pmap.get(p, a.transparent) for p in row] for row in px]
            # BM16 : largeur ST/xdiv (160px). Décimation horizontale (1 col / xdiv),
            # mais on garde la couleur opaque si présente dans le bloc (évite de
            # "trouer" un sprite fin en samplant pile sur une colonne transparente).
            if a.xdiv > 1:
                nw = w // a.xdiv
                newpx = []
                for row in remapped:
                    nrow = []
                    for i in range(nw):
                        blk = row[i*a.xdiv:(i+1)*a.xdiv]
                        opaque = [p for p in blk if p != a.transparent]
                        nrow.append(opaque[0] if opaque else a.transparent)
                    newpx.append(nrow)
                remapped, w = newpx, nw
            dst = outdir / f"Img_Roadside_{sid.upper()}_L{li}.png"
            write_png_indexed(dst, w, h, remapped, palette, a.transparent)
            n += 1
    print(f"{n} sprites convertis -> {outdir}")


if __name__ == '__main__':
    main(sys.argv[1:])
