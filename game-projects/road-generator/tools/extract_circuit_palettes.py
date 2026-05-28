#!/usr/bin/env python3
"""
Génère un PNG palette indexée par circuit + un index.html browseable.

Pour chaque .bin de FILE30, décode les 28 mots de palette ST (mode-effectif
après shift `(raw & $EEE) >> 1` du shifter) et produit :

  circuit_palettes/00_training_palette.png   ← PNG indexé mode='P' avec
                                               grille 16×2 cellules (28 utilisées)
  circuit_palettes/index.html                ← dashboard de tous les circuits
                                               avec métadonnées du catalog

Layout PNG :
  ┌──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┐
  │00│01│02│03│04│05│06│07│08│09│10│11│12│13│14│15│  ← Palette base
  ├──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┤
  │16│17│18│19│20│21│22│23│24│25│26│27│  (4 vides) │  ← Raster bands
  └──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴────────────┘

Mode 'P' (indexed) : pixel value = index palette ∈ [0..27]. Les indices
28..255 sont réservés à du noir (= cellules vides).

Usage :
    python3 tools/extract_circuit_palettes.py
"""

from __future__ import annotations

import argparse
import struct
import sys
from pathlib import Path
from PIL import Image

# ── Constantes layout ─────────────────────────────────────────────────────
PALETTE_NB_ENTRIES = 28
CELL_W = 32             # largeur cellule en pixels
CELL_H = 32             # hauteur cellule
COLS = 16               # cellules par ligne
ROWS = 2                # = 2 lignes (32 slots, 28 utilisés)
SEP = 2                 # séparateur entre cellules (= bordure)

# ── Décodage palette (= ce que voit le shifter ST runtime) ────────────────
def decode_palette_word(word: int):
    eff = (word & 0xEEE) >> 1
    return (eff >> 8) & 0x7, (eff >> 4) & 0x7, eff & 0x7


def palette_to_rgb_list(blob: bytes) -> list:
    """Renvoie les 28 couleurs au format (R, G, B) ∈ [0..252]^3 (×36)."""
    out = []
    for i in range(PALETTE_NB_ENTRIES):
        word = (blob[i*2] << 8) | blob[i*2+1]
        r, g, b = decode_palette_word(word)
        out.append((r * 36, g * 36, b * 36))
    return out


def parse_circuit_header(bin_path: Path):
    """Renvoie (nb_segments, palette_block_162oct, metadata_dict)."""
    data = bin_path.read_bytes()
    n = struct.unpack('>H', data[0:2])[0]
    block = data[2:2+162]
    meta = {
        'country':     block[56:66].decode('latin-1').rstrip('/'),
        'location':    block[66:98].decode('latin-1').rstrip('/').replace('/', ' '),
        'description': block[98:130].decode('latin-1').rstrip('/').replace('/', ' '),
        'hazards':     block[130:162].decode('latin-1').rstrip('/').replace('/', ' '),
    }
    return n, block[:56], meta


def build_palette_png(colors: list) -> Image.Image:
    """Construit un PNG mode='P' (indexed) avec grille 16×2 cellules."""
    w = COLS * CELL_W
    h = ROWS * CELL_H
    img = Image.new('P', (w, h), color=255)    # bg = index 255 (= noir)

    # Construit la palette 256 × 3 bytes
    pal = bytearray(768)
    for i, (r, g, b) in enumerate(colors):
        pal[i*3:i*3+3] = bytes([r, g, b])
    # index 255 = noir explicite pour le bg (déjà 0 par défaut, mais explicite)
    pal[255*3:255*3+3] = bytes([0, 0, 0])
    img.putpalette(bytes(pal))

    # Remplit chaque cellule utilisée avec son index
    pixels = img.load()
    for idx in range(PALETTE_NB_ENTRIES):
        row, col = divmod(idx, COLS)
        x0, y0 = col * CELL_W, row * CELL_H
        # bordure de 1px sur le contour (reste à 255 = noir)
        for y in range(y0 + SEP, y0 + CELL_H - SEP):
            for x in range(x0 + SEP, x0 + CELL_W - SEP):
                pixels[x, y] = idx
    return img


def emit_html_index(entries: list, out_path: Path):
    """Génère index.html avec table de tous les circuits + leur palette."""
    rows = []
    for name, meta, png_rel in entries:
        rows.append(f"""        <tr>
          <td class="name">{name}</td>
          <td class="meta">
            <div class="country">{meta['country']}</div>
            <div class="loc">{meta['location']}</div>
            <div class="desc">{meta['description']}</div>
            <div class="haz">{meta['hazards']}</div>
          </td>
          <td><img src="{png_rel}" alt="palette {name}" class="palette"></td>
        </tr>""")
    rows_html = "\n".join(rows)

    html = f"""<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="utf-8">
  <title>Lotus Esprit Turbo Challenge — Palettes circuits</title>
  <style>
    body {{ font-family: ui-sans-serif, system-ui, sans-serif; background: #1a1a1a; color: #ddd; margin: 0; padding: 24px; }}
    h1 {{ font-weight: 600; margin: 0 0 8px; }}
    p.subtitle {{ color: #888; margin: 0 0 24px; }}
    table {{ border-collapse: collapse; width: 100%; max-width: 1200px; }}
    td {{ padding: 12px; border-bottom: 1px solid #333; vertical-align: middle; }}
    td.name {{ font-family: ui-monospace, monospace; font-size: 14px; color: #ccc; white-space: nowrap; padding-right: 24px; }}
    td.meta {{ font-size: 13px; padding-right: 24px; }}
    .country {{ font-weight: 600; color: #fff; text-transform: uppercase; letter-spacing: 0.05em; }}
    .loc {{ color: #bbb; font-style: italic; }}
    .desc {{ color: #999; margin-top: 4px; font-size: 12px; }}
    .haz {{ color: #c88; font-size: 12px; }}
    img.palette {{ image-rendering: pixelated; image-rendering: crisp-edges; height: 48px; }}
  </style>
</head>
<body>
  <h1>Lotus Esprit Turbo Challenge — Palettes circuits</h1>
  <p class="subtitle">28 couleurs ST par circuit, normalisées 8-bit après transformation runtime du shifter <code>(raw &amp; $EEE) >> 1</code>. <strong>Zones</strong> : indices <span style="color:#9c9">[00..11] = palette fixe</span> (sprites bord-piste, voiture, HUD), <span style="color:#cc9">[12] = partagée</span> (transition sprites ↔ raster), <span style="color:#c99">[13..27] = raster route + dégradé ciel</span> (animé par Timer B et par position joueur). Validé par analyse d'usage de 500+ sprites extraits.</p>
  <table>
    <thead>
      <tr><th align="left">Circuit</th><th align="left">In-game</th><th align="left">Palette</th></tr>
    </thead>
    <tbody>
{rows_html}
    </tbody>
  </table>
</body>
</html>
"""
    out_path.write_text(html)


def main(argv):
    p = argparse.ArgumentParser(
        description="Génère PNG palette indexée par circuit + index.html")
    script_dir = Path(__file__).resolve().parent
    default_src = (script_dir.parent / 'lotus-ste' / 'doc' / 'extraction'
                   / 'circuits')
    default_out = (script_dir.parent / 'lotus-ste' / 'doc' / 'extraction'
                   / 'circuit_palettes')
    p.add_argument('--src', type=Path, default=default_src)
    p.add_argument('-o', '--output', type=Path, default=default_out)
    args = p.parse_args(argv[1:])

    if not args.src.is_dir():
        print(f"❌ Source introuvable : {args.src}", file=sys.stderr)
        return 1

    args.output.mkdir(parents=True, exist_ok=True)
    print(f"📂 Source : {args.src}")
    print(f"📂 Destination : {args.output}")

    entries = []
    bins = sorted(args.src.glob("*.bin"))
    for bin_path in bins:
        name = bin_path.stem
        try:
            _, pal_block, meta = parse_circuit_header(bin_path)
            colors = palette_to_rgb_list(pal_block)
            img = build_palette_png(colors)
            png_path = args.output / f"{name}_palette.png"
            img.save(png_path)
            entries.append((name, meta, f"{name}_palette.png"))
            print(f"  ✓ {name:20s} → {png_path.name} "
                  f"({meta['country']} / {meta['location']})")
        except Exception as e:
            print(f"  ✗ {name}: {e}", file=sys.stderr)

    # Génère l'index HTML
    index_path = args.output / "index.html"
    emit_html_index(entries, index_path)
    print(f"\n✓ {len(entries)} palettes générées + {index_path}")
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
