#!/usr/bin/env python3
"""Convert any picture into a TO8 BM16 background (160x200, 16 colours).

Two files come out, both using the SAME 1-based convention: PNG index k+1 is
ENGINE colour k, and PNG index 0 is unused.
  * the image PNG (160x200, 8-bit indexed -- PngToBottomUpB16Bin rejects
    anything else). The encoder emits `pixels[i] - 1` per pixel.
  * the palette PNG. PaletteTO8.getPaletteData reads indices 1..16.

BM16 pixels are twice as wide as they are tall, so the source is resized to
160x200 WITHOUT preserving its aspect ratio: the horizontal squash is what makes
it look right on a TO8.

Colours are snapped to the EF9369 DAC ladder (16 levels per channel) before the
final dither, so what you see here is what the machine shows -- the Java
generator would otherwise snap them behind your back and shift the dither.

Slots: the starfield palette already spends colours on fonts and stars
(1 = "by FX" cyan, 3 = title yellow, 4/5/6 = star greys). Those are reserved by
default; the picture gets colour 0 (forced pure black, it is what the act's
backgroundSolid and the star erase mask write) plus 2 and 7..15.

Usage:
    ./img2to8.py ~/Images/nebuleuse.jpeg -o ../game-mode/00/image/nebuleuse.png
"""
import argparse
import os

from PIL import Image

# Voltage readings off the EF9369 datasheet -- same table as PaletteTO8.java.
TO8_RGB = [0, 97, 122, 143, 158, 171, 184, 194, 204, 212, 219, 227, 235, 242, 250, 255]


def snap_channel(v):
    return min(TO8_RGB, key=lambda c: abs(c - v))


def snap(rgb):
    return tuple(snap_channel(c) for c in rgb)


def luma(rgb):
    r, g, b = rgb
    return 0.299 * r + 0.587 * g + 0.114 * b


def parse_slots(spec):
    """"0,2,7-15" -> [0, 2, 7, 8, ..., 15]"""
    out = []
    for part in spec.split(","):
        part = part.strip()
        if "-" in part:
            lo, hi = (int(x) for x in part.split("-"))
            out.extend(range(lo, hi + 1))
        else:
            out.append(int(part))
    if not all(0 <= s <= 15 for s in out):
        raise ValueError(f"slots must be 0..15, got {out}")
    return sorted(set(out))


def read_palette(path):
    """Read a palette PNG -> list of 16 engine colours (index k+1 -> colour k)."""
    pal = Image.open(path).getpalette()
    return [tuple(pal[(k + 1) * 3:(k + 1) * 3 + 3]) for k in range(16)]


QUANTIZERS = {
    "maxcoverage": Image.Quantize.MAXCOVERAGE,
    "octree": Image.Quantize.FASTOCTREE,
    "mediancut": Image.Quantize.MEDIANCUT,
}


def quantize_into(src, n, method):
    """Cut src into n colours, snapped to the TO8 ladder and deduped.

    MAXCOVERAGE is the default and not mediancut: median cut splits by pixel
    COUNT, so on a picture that is mostly dark (a starfield, a nebula) it spends
    every cluster inside the black background, and the EF9369 ladder -- whose
    first step is a brutal 0 -> 97 -- then snaps them all onto the same one or
    two entries. 11 colours collapsed to 3 on nebuleuse.jpeg that way.
    MAXCOVERAGE spreads over the colour VOLUME instead, so the bright galaxy
    keeps its share of the slots.
    """
    probe = src.quantize(colors=n, method=method)
    raw = probe.getpalette()[: n * 3]
    colours = [snap(tuple(raw[i * 3:i * 3 + 3])) for i in range(n)]
    # Snapping can collapse two near-identical colours onto one ladder point.
    seen = []
    for c in colours:
        if c not in seen:
            seen.append(c)
    return seen


def paste_overlay(out, ref, remap, spec, dither):
    """Composite a picture into the already-quantised image, palette unchanged.

    The overlay is matched against `ref` -- the colours the main picture already
    claimed -- instead of being quantised on its own, so it cannot take a new
    slot, and in particular cannot land on the star colours 4/5/6 (see
    starfield.asm: a nibble in 4..6 means "a star is here", and an overlay
    sitting on one of those would make stars skip their plot over it).
    An RGBA overlay is pasted through its own alpha; this one is opaque.
    """
    path, x, y, w, h = spec
    ov = Image.open(path)
    alpha = ov.convert("RGBA").split()[-1] if ov.mode in ("RGBA", "LA", "P") else None
    # Same squash as the main picture: a BM16 pixel is 2x wider than tall, so a
    # source square only looks square once its width is halved.
    ov = ov.convert("RGB").resize((w, h), Image.LANCZOS)
    q = ov.quantize(palette=ref, dither=Image.Dither.FLOYDSTEINBERG if dither else Image.Dither.NONE)
    mask = alpha.resize((w, h), Image.LANCZOS).point(lambda a: 255 if a > 127 else 0) if alpha else None
    out.paste(q.point(remap), (x, y), mask)
    return out


def build(src_path, out_path, pal_in, pal_out, slots, width, height, dither, method,
          overlay=None, overlay_dither=False):
    src = Image.open(src_path).convert("RGB")
    # No aspect ratio kept on purpose: a BM16 pixel is 2x wider than tall.
    src = src.resize((width, height), Image.LANCZOS)

    colours = quantize_into(src, len(slots), method)
    colours.sort(key=luma)
    # Slot 0 is the background the act clears to and the star erase mask writes.
    # It has to be true black or those writes would show as a colour shift.
    if 0 in slots:
        colours[0] = (0, 0, 0)
        # The darkest colour becoming black can duplicate the next one up.
        deduped = []
        for c in colours:
            if c not in deduped:
                deduped.append(c)
        colours = deduped

    used = slots[: len(colours)]

    # Re-quantize against the final, snapped palette so the dither is computed
    # against the colours the TO8 will actually display.
    ref = Image.new("P", (1, 1))
    flat = [ch for c in colours for ch in c]
    ref.putpalette(flat + [0, 0, 0] * (256 - len(colours)))
    quant = src.quantize(
        palette=ref,
        dither=Image.Dither.FLOYDSTEINBERG if dither else Image.Dither.NONE,
    )

    # quant indices are 0..len(colours)-1; remap them onto the engine slots.
    # +1 because PngToBottomUpB16Bin emits `pixels[i] - 1` for every pixel, i.e.
    # PNG index k IS engine colour k-1 -- the same 1-based convention
    # PaletteTO8.getPaletteData uses for the palette PNG (it reads indices 1..16).
    # Get this wrong and the picture still draws perfectly, just with every
    # colour off by one: index 0 wraps to colour 15 and the background goes white.
    remap = bytes(used[i] + 1 if i < len(used) else 0 for i in range(256))
    out = quant.point(remap)

    if overlay:
        out = paste_overlay(out, ref, remap, overlay, overlay_dither)

    engine = read_palette(pal_in) if pal_in else [(0, 0, 0)] * 16
    for slot, colour in zip(used, colours):
        engine[slot] = colour

    # Index k+1 = engine colour k, index 0 unused. Same table for both files.
    pal_data = [0, 0, 0] + [ch for c in engine for ch in c] + [0, 0, 0] * 239
    out.putpalette(pal_data)
    os.makedirs(os.path.dirname(os.path.abspath(out_path)), exist_ok=True)
    out.save(out_path)

    pimg = Image.new("P", (16, 1), 0)
    pimg.putpalette(pal_data)
    pimg.putdata(bytes(range(1, 17)))
    os.makedirs(os.path.dirname(os.path.abspath(pal_out)), exist_ok=True)
    pimg.save(pal_out)

    print(f"wrote {out_path} ({width}x{height}, {len(colours)} colours)")
    print(f"wrote {pal_out}")
    for slot, colour in zip(used, colours):
        gr0b = "".join(
            f"{TO8_RGB.index(v):x}" for v in (colour[1], colour[0])
        ) + "0" + f"{TO8_RGB.index(colour[2]):x}"
        print(f"  colour {slot:2d} = RGB{colour} -> ${gr0b}")


def main():
    here = os.path.dirname(os.path.abspath(__file__))
    default_pal = os.path.join(here, "..", "game-mode", "00", "image", "palette.png")

    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("source")
    ap.add_argument("-o", "--out", required=True, help="indexed image PNG to write")
    ap.add_argument("-p", "--palette-out", help="palette PNG to write (default: alongside --out)")
    ap.add_argument("--palette-in", default=default_pal,
                    help="palette PNG whose reserved colours are kept (default: the starfield one)")
    ap.add_argument("--slots", default="0,2,7-15",
                    help="engine colours the picture may claim (default: 0,2,7-15 -- "
                         "keeps 1 cyan, 3 yellow, 4/5/6 star greys)")
    ap.add_argument("--width", type=int, default=160)
    ap.add_argument("--height", type=int, default=200)
    # Dithering is OFF by default. Floyd-Steinberg speckles the near-black
    # background with isolated bright pixels, which on a starfield both reads as
    # noise and competes with the real stars. It also matters that black stays
    # black: the star erase mask writes colour 0, so it is only invisible where
    # the picture is already colour 0.
    ap.add_argument("--dither", action="store_true", help="Floyd-Steinberg (noisy on dark pictures)")
    ap.add_argument("--quantizer", default="maxcoverage", choices=sorted(QUANTIZERS),
                    help="mediancut collapses on dark pictures -- see quantize_into()")
    ap.add_argument("--overlay", metavar="PATH:X,Y,W,H",
                    help="composite a second picture in, reusing the main one's colours")
    # Tried on alien-xenon over the nebula palette: dithering made it WORSE, not
    # better. The palette has no greys, so Floyd-Steinberg fakes them by mixing
    # magenta and blue, and at 40x80 that speckle swallows the face. Borrowed
    # palettes are exactly where dithering has the least to work with.
    ap.add_argument("--overlay-dither", action="store_true",
                    help="dither the overlay (usually worse: see the note in main())")
    args = ap.parse_args()

    overlay = None
    if args.overlay:
        path, _, rect = args.overlay.rpartition(":")
        if not path:
            ap.error("--overlay needs PATH:X,Y,W,H")
        x, y, w, h = (int(v) for v in rect.split(","))
        overlay = (path, x, y, w, h)

    pal_out = args.palette_out or os.path.join(os.path.dirname(os.path.abspath(args.out)), "palette.png")
    build(args.source, args.out, args.palette_in, pal_out,
          parse_slots(args.slots), args.width, args.height, args.dither,
          QUANTIZERS[args.quantizer], overlay, args.overlay_dither)


if __name__ == "__main__":
    main()
