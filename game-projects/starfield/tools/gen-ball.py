#!/usr/bin/env python3
"""Render a lit 4x8 sphere and emit its 4 pre-shifted compiled draw routines.

Writes global/ball-sprites.asm. Re-run after changing the light or ramp.

WHY PROCEDURAL: the ball is 4x8 = 32 pixels. Any real sprite downscaled that far
is mush; at this size every pixel is a decision, so the sphere is computed and
the specular highlight lands exactly where we want it.

WHY 4 VARIANTS: one BM16 byte column spans 4 px (2 in RAM A + 2 in RAM B), so a
sprite can only be placed on a 4px grid unless you pre-shift it. One compiled
routine per `x AND 3`.

BM16 layout (same rules as global/starfield.asm):
    byte offset = y*40 + (x>>2)
    plane       = RAM B ($A000) if (x AND 2) else RAM A ($C000)
    nibble      = low if (x AND 1) else high
A 4x8 ball is square on screen: a BM16 pixel is twice as wide as it is tall.

Routine contract: U = $C000 + by*40 + (bx>>2), the RAM A byte of the ball's
top-left column. RAM B is the same offset minus $2000.
"""
import math
import os

W, H = 4, 8                  # ball size in BM16 pixels
RAMB_DELTA = -0x2000
ROW = 40                     # bytes per scanline per bank

# Engine colour -> its LUMINANCE, for the nearest-level match below.
# The palette is full (see the design doc), so the ball borrows a ramp rather
# than claiming slots. Two deliberate choices here:
#  - the shadow end is 2 (0,0,122 dark blue) and 9 (97,122,184 blue-grey), NOT
#    colour 0. Colour 0 is black, i.e. the background: a physically-correct
#    unlit side would make the bottom of the ball vanish into space. The blue
#    shadow also reads as chrome reflecting the nebula, which is what we want.
#  - 11 (143) and 4 (158) are only 15 apart and barely separable; they are both
#    kept because they cost nothing, but the volume really comes from 2/9/5/6.
RAMP = [(2, 14), (9, 122), (11, 143), (4, 158), (5, 219), (6, 255)]

# Light from the upper left, toward the viewer.
LIGHT = (-0.5, -0.6, 0.65)


def norm(v):
    m = math.sqrt(sum(c * c for c in v))
    return tuple(c / m for c in v)


def shade():
    """-> dict (px, py) -> engine colour, for opaque pixels only."""
    lx, ly, lz = norm(LIGHT)
    out = {}
    for py in range(H):
        for px in range(W):
            # Work in SCREEN units: a pixel is 2 units wide, 1 tall, so the
            # 4x8 ball is an 8x8 square and the sphere is round.
            sx = px * 2 + 1.0
            sy = py + 0.5
            dx, dy = (sx - 4.0) / 4.0, (sy - 4.0) / 4.0
            r2 = dx * dx + dy * dy
            if r2 > 1.0:
                continue                      # outside the sphere -> transparent
            nz = math.sqrt(max(0.0, 1.0 - r2))
            diff = max(0.0, dx * lx + dy * ly + nz * lz)
            # Specular: reflect the view vector (0,0,1) about the normal.
            ndv = nz
            rx, ry, rz = (2 * ndv * dx, 2 * ndv * dy, 2 * ndv * nz - 1.0)
            spec = max(0.0, rx * lx + ry * ly + rz * lz) ** 24
            i = 0.10 + 0.75 * diff + 0.9 * spec      # ambient + diffuse + highlight
            v = max(0, min(255, int(i * 255)))
            out[(px, py)] = min(RAMP, key=lambda c: abs(c[1] - v))[0]
    return out


def emit_variant(pix, shift):
    """Compiled draw routine for bx AND 3 == shift."""
    # Group the ball's pixels by the byte they land in.
    # bytes[(plane, offset)] = {nibble: colour}
    cells = {}
    for (px, py), col in pix.items():
        x = shift + px                        # x relative to the column base
        relcol = x >> 2
        plane = 1 if (x & 2) else 0           # 1 = RAM B
        off = py * ROW + relcol
        cells.setdefault((plane, off), {})[x & 1] = col

    lines = [f"* --- shift {shift}: ball at bx where (bx AND 3) == {shift} ---",
             f"ball_draw_{shift}"]
    for (plane, off), nib in sorted(cells.items()):
        addr = off + (RAMB_DELTA if plane else 0)
        hi, lo = nib.get(0), nib.get(1)       # nibble 0 = high (even x), 1 = low
        if hi is not None and lo is not None:
            # Both nibbles are ours: no read needed, just stamp the byte.
            lines.append(f"        lda   #${hi << 4 | lo:02X}")
            lines.append(f"        sta   {addr},u")
        elif hi is not None:
            lines.append(f"        lda   {addr},u")
            lines.append(f"        anda  #$0F")        # keep the neighbour's pixel
            lines.append(f"        ora   #${hi << 4:02X}")
            lines.append(f"        sta   {addr},u")
        else:
            lines.append(f"        lda   {addr},u")
            lines.append(f"        anda  #$F0")
            lines.append(f"        ora   #${lo:02X}")
            lines.append(f"        sta   {addr},u")
    lines.append("        rts")
    return "\n".join(lines)


def main():
    pix = shade()

    art = "\n".join("* " + "".join(
        {2: ".", 9: "-", 11: ":", 4: "o", 5: "O", 6: "@"}.get(pix.get((px, py)), " ")
        for px in range(W)) for py in range(H))

    here = os.path.dirname(os.path.abspath(__file__))
    out = os.path.join(here, "..", "global", "ball-sprites.asm")
    os.makedirs(os.path.dirname(out), exist_ok=True)

    body = [
        "* ==========================================================================",
        "* ball-sprites.asm — GENERATED by tools/gen-ball.py, do not hand-edit.",
        "* --------------------------------------------------------------------------",
        "* A 4x8 lit sphere (square on screen: a BM16 pixel is 2x wider than tall),",
        "* in four pre-shifted variants because one BM16 byte column spans 4 px and a",
        "* sprite cannot sit off that grid without one compiled routine per x AND 3.",
        "*",
        "* In:  U = $C000 + by*40 + (bx>>2)   (RAM A byte of the ball's top-left column)",
        "* RAM B is reached at -$2000. Clobbers A only.",
        "*",
        "* Colours are BORROWED from the full palette (2, 9, 11, 4, 5, 6): the nebula,",
        "* the title, the by-FX line and the stars already own all 16 slots, so the ball",
        "* claims none. The shadow end is blue (2, 9) rather than colour 0, because 0 is",
        "* the background: a correctly-unlit side would make the ball's bottom vanish.",
        "* Using the star colours 4/5/6 is safe ONLY because BallsRestore wipes every",
        "* ball pixel before StarfieldRender's 'nibble in 4..6 means star' test runs.",
        "*",
        "* Shape (. blue-2  - blue-9  : 143  o 158  O 219  @ 255):",
        art,
        "* ==========================================================================",
        "",
        "ball_routines",
    ] + [f"        fdb   ball_draw_{s}" for s in range(4)] + [""]

    for s in range(4):
        body.append(emit_variant(pix, s))
        body.append("")

    open(out, "w").write("\n".join(body) + "\n")
    print("wrote", os.path.normpath(out))
    print(art)
    n = sum(1 for _ in pix)
    print(f"{n} opaque pixels of {W*H}")


if __name__ == "__main__":
    main()
