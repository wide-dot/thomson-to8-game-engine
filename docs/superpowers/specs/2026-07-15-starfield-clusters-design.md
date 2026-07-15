# Starfield — star clusters with derived satellites

## Goal

Make the starfield cheaper at the same density, by generating only a few *master*
stars at random and deriving the rest as fixed offsets from them. Each master
plus 6 derived satellites reads as a cluster in which only one star is really
real.

## Baseline (measured, not assumed)

The end state (72 stars + balls + two band restores + the scenario tick) runs at
`gfxlock.frameDrop.count = 3`, i.e. **166 renders per 500 frames = 16.6 Hz**.
`gfxlock.bufferSwap.count` at `$65E2` increments once per render, which is how to
measure this. Any claim about the optimisation must beat those numbers.

## The enabling constraint: dx must be a multiple of 4

BM16 addressing is `byte = y*40 + (x>>2)`, plane = RAM B if `(x AND 2)`, nibble =
low if `(x AND 1)`. For a satellite at `(x+dx, y+dy)`, if **`dx ≡ 0 (mod 4)`**:

- `(x+dx)>>2 == (x>>2) + dx/4` — exact, no carry out of the low 2 bits
- `(x+dx) AND 2 == x AND 2` — **same plane**
- `(x+dx) AND 1 == x AND 1` — **same nibble**

So the satellite's address is exactly `master_addr + (dy*40 + dx/4)`: a
**constant** 16-bit delta, and it shares the master's plane and nibble.

This is the whole optimisation. Today every one of 72 stars pays the full address
computation (plane select, `x>>2`, `abx`, nibble select). With the constraint that
happens **once per cluster** and each member is one `leax d,x`.

If `dx` were arbitrary the plane and nibble would differ per member and per frame
(they depend on the master's live x), each satellite would need the full
computation, and there would be no saving at all. `dx ≡ 2 (mod 4)` is not enough:
it preserves the nibble but *flips* the plane, and which direction it flips
depends on the master's current `x AND 2`, so the delta stops being constant.

Vertical offsets are unconstrained — `dy` only scales `y*40`. `|dy| <= 6` is a
LOOKS choice, not a correctness one: a BM16 pixel is twice as wide as it is tall
and `dx` is stuck on a 4px grid, so a cluster spanning `|dx| <= 8` is already 32
SCREEN units across. `|dy| <= 3` made it 7 tall — a flat horizontal smear rather
than a grouping.

## Shape

- 3 masters per layer x 3 layers = **9 masters**, 7 members each = **63 drawn
  stars** (against 72 today).
- Cluster record: x (8.8), y, colour x2 (both nibble alignments), speed, cached
  `y*40`, pattern — 10 bytes x 9 = **90 bytes, down from 648**.
- Satellites store nothing. They are derived every frame.

Cost, per frame: **9 address computations + 63 plots**, against today's 72 + 72.

## `sf_active` stays in DRAWN STARS, not clusters

The scenario's t=6s phase shows one star and captions it `THIS WAS THE ONE STAR
STARFIELD DEMO`. If `sf_active` counted clusters, `sf_active=1` would draw 7 stars
and the caption would be a lie.

So the render walks clusters with a countdown seeded from `sf_active`, drawing
`min(7, remaining)` members each and stopping at zero. `sf_active=1` draws cluster
0's master alone — which the existing round-robin already makes the white fast one.
No division is needed anywhere.

The ramp then fills clusters progressively, so they visibly *grow* as the field
builds. `NUM_STARS` becomes 63 and the scenario's `SC_RAMP` target follows it — as must its
RATE, which is `(NUM_STARS-1)*256/250`: leave it at the 72-star field's 72 and the
ramp stalls short and `ScClamp` snaps the remainder in as a visible jump.

Erase entries stay **per drawn star** (63 x 4 x 2 pages = 504 bytes, down from 576).
Entry index = the global drawn index, which is stable because drawing always
starts at cluster 0 member 0 and proceeds in order, and `sf_active` only grows.
Folding the erase per-cluster would save ~70 bytes and complicate the partial
cluster; not worth it.

## Edges

Members are clipped on **both** axes, gated by a single test on the MASTER: with
`|dx| <= 20` and `|dy| <= 20`, a master at `20 <= x <= 139` and `20 <= y <= 179`
cannot clip anything, so the member loop skips the tests entirely. That fast path
covers ~60% of clusters.

**Rejected: clamping the master's spawn `y`** to `[DY_MAX, 199-DY_MAX]` so a
cluster can never leave the screen vertically and no member ever needs a y test.
It is free and it works while `DY_MAX` is small, but it starves the screen edges
as `DY_MAX` grows: at `|dy| <= 20`, row 0 is reachable only by a master at exactly
`y=20` with `dy=-20`, so rows 0..40 ramp from ~4% density to full — a bald band
over a fifth of the screen. Masters therefore spawn uniformly over all 200 rows
and members are clipped instead.

Both tests are 16-bit. For x because it is 0..159 and `$9F` is negative as a
signed byte, so an 8-bit test would call a star at x=159 "off the left edge". For
y because the test is on the ROW OFFSET rather than on y: `cl_row` is already
`y*40` and the generator supplies `dy*40`, so it costs one add and two compares
against `[0, 8000)` and no multiply.

**The vertical test is not optional.** A member at `y<0` addresses below its plane
base — for RAM B that is below `$A000`, i.e. straight into engine RAM, where it
silently rewrites the palette. Removing the clamp without adding the test turned
the whole picture blue.

Clipped members simply do not plot and leave `er_addr = 0`, so the erase pass
ignores them — the same mechanism the "another star is already here" skip uses.
Note the erase runs BEFORE the clip test, so a member that was on screen last
frame and is clipped this frame is still erased rather than stranded.

Result: a cluster dissolves member by member at the left edge and reforms at the
right. That is what stars do today when they wrap; it just happens to 7 at once.

## Patterns

4 patterns, one drawn per master at spawn and re-drawn on respawn, so the sky is
not 9 copies of one shape. `cl_pat` holds the pre-multiplied byte offset into the
pattern table, so the render needs no multiply.

Each pattern is **7 entries** — the master at `(0,0)` included — so the member loop
is uniform with no special case for the master. Entry = `fdb delta` (`dy*40 +
dx/4`) + `fdb dx16` (sign-extended, for the clip test) = 4 bytes. 4 x 7 x 4 = **112
bytes**.

Generated by `tools/gen-clusters.py`, consistent with `gen-ball.py` /
`gen-orbit.py`. The generator **enforces** the constraints that make this work —
`dx ≡ 0 mod 4`, `|dx| <= 8`, `|dy| <= 6`, no two members on the same pixel — so the
invariant lives in the tool rather than in a comment a later edit can violate.

## The nibble is decided once per cluster

Every member shares the master's nibble, so the render picks the nibble path once
per cluster and patches the member loop's **immediate operands** (the engine's own
idiom — see `DrawText_pos equ *-2`): the keep-mask, the pre-shifted colour, the
"is this a star" bounds (4..6 or 64..96), and the erase mask.

That keeps the member loop uniform and on 2-cycle immediate addressing, instead of
either duplicating the loop per nibble (~40 lines) or paying 5-cycle direct
addressing on six operands x 63 members.

## Components

| File | Change |
|---|---|
| `tools/gen-clusters.py` | **new** — emits the 4 patterns, enforcing the offset constraints |
| `global/clusters.asm` | **new, generated** — `cluster_pat` |
| `global/starfield.asm` | star records become cluster records; init seeds 9 masters; render derives 7 members per cluster |
| `global/scenario.asm` | `SC_RAMP` target AND rate follow `NUM_STARS` (63) |

## Verification

- **Cost, against the baseline above**: `frameDrop.count` and renders-per-500-frames
  in the same end state.
- **Density**: 63 star pixels, split ~21/21/21 across colours 4/5/6 (the
  round-robin must survive). Count them BEFORE the balls appear at t=39s: the
  balls borrow colours 4/5/6, so a whole-screen count in the end state is
  inflated by ~96 ball pixels and means nothing.
- **The scenario still holds**: `sf_active=1` draws exactly ONE pixel and it is
  colour 6. This is the check that the drawn-star unit was preserved.
- **Edges**: no star pixel outside x 0..159 / y 0..199, and no cluster wrapping to
  the wrong row — the failure mode if the clip is wrong is a star appearing on the
  opposite edge one row off.
- **Histogram conservation** over 3000+ frames: no colour may grow. This is the
  check that caught the signed-offset bug in the text oscillation.

## Measured result (not the estimate)

| Config | masters x members | renders / 500 | rate | stars |
|---|---|---|---|---|
| baseline, individual stars | — | 166 | 16.6 Hz | 72 |
| clusters, tight (dx±8, dy±6) | 9 x 7 | **222** | **22.2 Hz** | 63 |
| clusters, diffuse (dx±20, dy±20) | 9 x 7 | 190 | 19.0 Hz | 63 |
| **clusters, very diffuse (dx±28, dy±28)** | **18 x 4** | **166** | **16.6 Hz** | 72 |
| same build, stars off (floor) | — | 250 | 25.0 Hz | 0 |

**The optimisation and the diffuse look are directly opposed, and the last row is
the optimisation fully spent.** Three things each cost part of it:

- **more masters** — the address computation is the thing being saved, and it is
  paid once per master. 18 masters saves only 54 of 72; 72 masters saves nothing.
- **fewer members** — each member is a nearly-free `leax d,x` amortising its
  master's setup. Fewer per master means less to amortise it over.
- **wider bounds** — they are what lets the member loop skip the clip tests. At
  ±8/±6 ~90% of clusters take the fast path; at ±28/±28 only ~47% do.

At 18 x 4 with ±28 the field is indistinguishable from a random starfield and runs
at exactly the baseline rate. That is a legitimate choice — same speed, a better
distribution, 468 fewer bytes of records — but nothing is being bought by the
cluster machinery at that setting.

**The spec's "~40% cheaper" estimate was wrong; the real per-star saving is ~16%**
(0.0118 vs 0.0140 frames/star). What was eliminated is the address computation,
about 25 of the ~90 cycles a plot costs — not the plot. At 4 masters/layer the
whole saving went into the 12 extra stars and the frame rate did not move at all.

The jump to 22.2 Hz at 3 masters/layer is **non-linear** and that matters: the
render rate is quantised to whole 50Hz frames, so at 84 stars the loop lands just
*over* the 2-frame boundary and is rounded up to 3, while at 63 it fits inside 2
most of the time. The field sits right on that cliff — small additions can cost a
third of the frame rate, and the measurement is worth repeating after any change.

The starfield is about one third of the frame (25.0 Hz with it off, 16.6 with it
on at 72 stars). The rest is the two band restores, the balls, and DrawText.

## Side effect: the field got faster — since FIXED

Star speeds used to be per RENDER and deliberately not frame-drop compensated, so
every improvement to the render rate silently sped the field up (16.6 -> 22.2 Hz
made it 34% faster; 16.6 -> 25.0 Hz made it 50% faster).

That is now fixed: speeds are 8.8 px per 50Hz FRAME and StarfieldUpdate
multiplies by gfxlock.frameDrop.count, so the field is wall-clock stable. The old
objection — that a fractional speed renders 1,0,1,0 — does not survive
compensation: x is an 8.8 accumulator, so the fraction is carried rather than
lost, and the stutter came from advancing by a fraction once per RENDER.

## lwasm: StarfieldRender's locals had to become globals

The routine needs ~29 `@local` symbols (up from 13), and past a point lwasm simply
stops resolving them: the early ones bind, the later ones report `Undefined symbol
@xxx`. It assembles clean standalone and fails only in the full build, so the
limit is per translation unit rather than per file. The scratch and the patched
immediates are therefore global (`sfr_*`) — the same thing `band.asm` already does
for its shared scratch, and for the same reason.
