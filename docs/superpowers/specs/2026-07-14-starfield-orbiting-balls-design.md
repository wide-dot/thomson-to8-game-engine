# Starfield — 8 balls orbiting the alien portrait

## Goal

Eight 4x8 pixel chrome balls orbit the `alien-xenon` portrait, spaced 45 degrees
apart, rotating fast (~0.64 s per revolution), drawn in front of everything.

## Geometry (verified, not assumed)

A BM16 pixel is twice as wide as it is tall, so the 40x80 px alien is an 80x80
**screen-unit square**, and a circle that fully encloses it needs radius
40*sqrt(2) ~= 57. Centred on the alien (y=151) that circle would run to y=212 on
a 200-row screen: **it does not fit**. Moving the alien up to make room pushes it
into the title (y=88) and "by FX" (y=100).

Resolved by using a **tight orbit** (radius 40 screen units) that touches the
alien's edge midpoints, so the balls pass *over* the portrait's corners. This
reads as balls orbiting in front of the portrait, and it fits exactly.

- Centre (80, 151), rx = 20 px, ry = 40 rows. The 1:2 ratio is what makes it
  render as a circle rather than an ellipse.
- Ball top-left sweeps x 58..98, y 107..187; with the 4x8 body it covers
  x 58..101, y 107..194 -> byte columns 14..25 (12), rows 107..194 (88).
- 64 steps per revolution; ball k sits at step `(phase + k*8) AND 63`.

## The erase problem, and why save-under is wrong here

The balls draw **last**, so their background is the dynamic scene (nebula +
stars + text). Save-under of a dynamic background records those moving pixels as
"background" and paints them back later as permanent ghosts — the same failure
that already ruled save-under out for the oscillating text (see
`global/textband.asm`).

Instead, generalise the textband trick: snapshot the **pristine nebula** under
the whole annulus ONCE at init, before anything has drawn over it, then have
each ball restore its own 32-byte box from that snapshot. No save-under at all.
The box returns to pure nebula; stars and text then repaint themselves.

Snapshot: 12 * 88 * 2 = **2112 bytes**. Resident RAM free: 7643. Fits.

## Render order (load-bearing)

```
_gfxlock.on
  BallsRestore        ; FIRST: wipes last frame's balls, so StarfieldRender's
                      ; save-under can never read a ball pixel
  TextBandRestore
  StarfieldUpdate / StarfieldRender
  RunObjects          ; title + by FX
  BallsDraw           ; LAST: in front of everything
_gfxlock.off
```

`BallsRestore` and `TextBandRestore` overlap on rows 107..108. Both write
pristine nebula, so the overlap is idempotent.

Previous position is tracked **per page** (gfxlock alternates buffers, so a
page's last content is two renders old). Because every ball derives from one
shared phase, only the phase needs storing: one byte per page, plus a valid flag.

## Colours

The palette is full: 0/2/7-15 nebula, 1 by FX, 3 title, 4/5/6 stars. The ball
claims no slot; it reuses the existing grey ramp — 0 (rim), 11=143, 4=158,
5=219, 6=255 (highlight).

Using 4/5/6 does **not** break `StarfieldRender`'s "a nibble in 4..6 means a star
is here" test, because `BallsRestore` erases every ball pixel before that test
runs. The ordering protects the invariant, not the colour choice.

## Components

| File | Role |
|---|---|
| `tools/gen-ball.py` | renders a lit 4x8 sphere; emits 4 pre-shifted compiled draw routines (x%4 = 0..3) |
| `tools/gen-orbit.py` | emits the 64-step orbit table: vram offset, snapshot offset, shift |
| `objects/balls/ball-sprites.asm` | generated sprite code |
| `objects/balls/orbit.asm` | generated table |
| `global/balls.asm` | `BallsSnapshot` (init), `BallsRestore`, `BallsDraw`, state |

Sprites need 4 pre-shifted variants because one BM16 byte column spans 4 px, so
x resolution below 4 px requires a variant per `x AND 3`.

Compiled sprite contract: `U` = `$C000 + by*40 + (bx>>2)` (RAM A byte of the
ball's top-left column). RAM B is reached at `-$2000`. Bytes with both nibbles
opaque are written directly; bytes with one opaque nibble are read-modify-write;
fully transparent bytes are skipped.

## Motion

Phase advances by `gfxlock.frameDrop.count * ORB_SPEED8` in 8.8 fixed point, i.e.
in 50Hz frames, so the rotation speed is wall-clock stable and independent of
frame drops — the convention the framework's frameDrop indicator exists for.

**Speed has an aliasing ceiling.** The balls are identical and 8 steps (45°)
apart, so rotating the ring by 8 steps maps it onto itself: any per-displayed-
frame step near 8 is indistinguishable from standing still. The first version ran
at 2 steps per 50Hz frame, which at the loop's ~25Hz meant **4 steps = 22.5° per
drawn image — exactly half the spacing**, so the ring alternated between two
configurations and read as flicker rather than rotation. `ORB_SPEED8 = $80`
(½ step per 50Hz frame) gives exactly 1 step (5.6°) per drawn image, 2.56 s per
revolution, and divides the 2-frame render period exactly so it cannot stutter
1,2,1,2 the way the sub-pixel star speeds once did.

## Budget

~2560 cycles restore + ~1000 cycles draw = ~3500/frame, against ~40000 available
at the loop's ~25Hz.

## Verification

Boot the floppy in TOJE (`run_frames` only — never `run_until_pc` for long runs;
it desyncs the machine and produces false negatives). Then:
- balls visible, 8 of them, evenly spaced, orbiting;
- run 3000+ frames and check the colour histogram is conserved: no growth of any
  colour means no ghost/smear accumulation. This is the check that caught the
  signed-offset bug in the text oscillation; a visual crop alone missed it.
