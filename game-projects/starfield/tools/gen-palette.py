#!/usr/bin/env python3
"""Generate game-mode/00/image/palette.png for the starfield.

This only seeds the RESERVED colours (fonts + stars). img2to8.py rewrites the
same palette.png with a picture's colours merged into the free slots, so running
this script afterwards silently drops them -- re-run img2to8.py if you do.

PaletteTO8.getPaletteData reads PNG palette indices 1..16 -> engine colours 0..15
(PNG index k = engine colour k-1). RGB is snapped to the EF9369 DAC ladder
to8RGB = {0,97,122,143,158,171,184,194,204,212,219,227,235,242,250,255}, so grey
levels 4/10/15 are RGB 158/219/255.

The colour map is dictated by the fonts: every compiled glyph hard-codes its
palette index, so a text's colour IS its font variant:
    fnt_4x6_shd      -> colour 3    (title)
    fnt_4x6_shd_dis  -> colour 1    ("by FX", faded at runtime)
    fnt_4x6_shd_sel  -> colour 15   (spare)
The stars therefore live on colours 4/5/6, which no font touches, so fading the
"by FX" colour cannot disturb them.
"""
from PIL import Image
import os

pal = [0, 0, 0] * 256


def setc(engine_colour, r, g, b):
    """Set an ENGINE colour (0..15). The PNG palette index is engine_colour+1."""
    i = engine_colour + 1
    pal[i * 3:i * 3 + 3] = [r, g, b]


pal[0:3] = [0, 0, 0]        # PNG index 0: ignored by the palette generator
setc(0, 0, 0, 0)            # 0 = black background (never plotted)
setc(1, 0, 255, 255)        # 1 = "by FX" cyan $0FF (fnt_4x6_shd_dis; ramped 0->F)
setc(2, 0, 0, 0)            # 2 = unused
setc(3, 255, 255, 0)        # 3 = title yellow $FF0 (fnt_4x6_shd)
setc(4, 158, 158, 158)      # 4 = star slow $444
setc(5, 219, 219, 219)      # 5 = star mid  $AAA
setc(6, 255, 255, 255)      # 6 = star fast $FFF
# 7..15 stay black (15 is reachable via fnt_4x6_shd_sel if ever needed)

img = Image.new("P", (16, 1), 0)
img.putpalette(pal)
img.putdata(bytes(range(16)))
out = os.path.join(os.path.dirname(__file__), "..", "game-mode", "00", "image", "palette.png")
os.makedirs(os.path.dirname(out), exist_ok=True)
img.save(out)
print("wrote", os.path.normpath(out))
