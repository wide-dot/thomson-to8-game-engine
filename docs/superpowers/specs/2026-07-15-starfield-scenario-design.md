# Starfield — scripted intro scenario

## Goal

Turn the starfield mode from "everything on at once" into a ~39 second scripted
sequence: black screen, title fade, music, one star, two captions, the field
filling up, the nebula revealing itself, and finally the balls.

## The central idea

**Almost nothing is created or destroyed — it is revealed.** `LoadAct` already
blits the nebula and the xenon portrait into both video pages at init, and the
title object already draws itself every frame from frame 0. They are invisible
only because their palette entries are black. The scenario is therefore mostly a
palette schedule, plus a handful of gates for the things that palette cannot
express.

Two things palette *cannot* express, and why:

- **The balls** borrow colours 2, 9, 11, 4, 5 and 6 from other elements. They own
  no slot, so there is no entry to keep black. Their appearance must gate the
  drawing.
- **The stars** are 72 independent objects; "one star" is a count, not a colour.

## Palette groups

The palette is full and already partitioned by owner, which is what makes this
schedule possible at all:

| Entries | Owner | Scenario treatment |
|---|---|---|
| 0 | background black | never touched |
| 1 | "by FX" text | owned by `byfx.asm`'s ping-pong; scenario only gates when it starts |
| 3 | title **and captions** | faded in at t=0 |
| 4, 5, 6 | stars | **lit from frame 0** — see below |
| 2, 7–15 | nebula + xenon | faded in at t=31s |

Stars need no fade. With `sf_active = 0` nothing is drawn, so their colours can be
at full brightness from the first frame and cost nothing. Adding a fade for them
would be three palette entries of machinery to hide pixels that do not exist.

## `pal_scaled` — a constant, because the fade is a property of the hardware

**The fade must be gamma-correct, not linear in the index.** A palette nibble is an
INDEX into the EF9369 DAC ladder
`{0,97,122,143,158,171,184,194,204,212,219,227,235,242,250,255}`, not a
brightness, and that ladder's first step jumps straight to 38%. Scaling the
*index* linearly would put a target of 15 at index 7 (=194, i.e. 76% brightness)
by the halfway point: the fade would arrive almost entirely in its first few steps
and then crawl. So each channel is scaled in **RGB space** — `want =
to8RGB[target] * L / 16` — and matched back to the nearest ladder index.

**The key realisation: `nearest(to8RGB[idx] * L / 16)` depends only on the DAC
ladder — hardware — and not on the palette at all.** So the whole fade is a
constant:

```
pal_scaled   ; 17 rows (L = 0..16) x 16 ladder indices = 272 bytes
```

Row L holds the 16 indices scaled to L/16 brightness. Row 16 is the identity, so a
fade to 16 reproduces the authored colour exactly; row 0 is all black. Rows are 16
bytes wide so indexing is `(L<<4)|idx` with no multiply.

`PalGroupSet(group, L)` reads each entry's authored G/R/B and writes
`pal_scaled[L][G]`, `pal_scaled[L][R]`, `pal_scaled[L][B]` — cheap enough to run
every frame of a fade. The authored palette is snapshotted into `pal_authored`
(32 bytes) at init, because the fades overwrite `Pal_starfield` and every fade
must be computed from the original.

**Rejected: building a 544-byte ramp at init from `Pal_starfield`** (816
nearest-match scans). It produced byte-identical output but cost ~0.4s, and that
much time inside the init sequence broke the boot. The constant table is smaller,
free, and needs no derivation.

**Also rejected: a `gen-palfade.py` reading `palette.png`.** It would have to
re-implement the java builder's palette index convention, which has already caused
one bug here (`PngToBottomUpB16Bin` emits `pixels[i] - 1`, so PNG index k is engine
colour k-1). The constant table sidesteps the question by not depending on the
palette at all.

## What a fade actually looks like, and why

The intermediate frames of the nebula fade are **posterised**, not a smooth dim:
around level 7 all ten nebula colours collapse onto ladder indices 0/1/2 and the
hues flatten toward red.

This is the hardware, not a bug, and it is not fixable. The DAC's first non-zero
step is 38% brightness, so **below 38% there is only black** — a dim version of a
ten-colour picture is not representable on an EF9369. Confirmed by reading the
live palette mid-fade: every entry held exactly its computed value.

## Gates

Written only by `scenario.asm`; every reader stays dumb.

| Gate | Type | Read by | Meaning |
|---|---|---|---|
| `sc_music_on` | flag | `UserIRQ` | music players ticked or not |
| `sc_byfx_on` | flag | `byfx.asm` Init | object stays inert until set |
| `sc_osc_on` | flag | `byfx.asm` Live | x fixed at 68, or oscillating |
| `sc_msg` | word | `title.asm` Live | pointer to caption text, 0 = none |
| `sf_active` | byte | `StarfieldUpdate` / `StarfieldRender` | how many stars exist |
| `sc_balls_on` | flag | `BallsRestore` / `BallsDraw` | balls drawn or not |

## Silence before t=3s

`UserIRQ` currently calls `YVGM_MusicFrame` and `vgc_update` unconditionally at
50Hz. Both `_music.init.*` calls stay where they are — they only set up player
state, and moving them into the script would mean initialising a music player
from inside the render loop — but the two per-frame ticks in `UserIRQ` are gated
behind `sc_music_on`. A player that is never ticked emits nothing, so the chips
stay at their reset state and the screen is silent until the script says
otherwise.

## Init ordering (load-bearing)

`ScenarioInit` snapshots the authored `Pal_starfield` into `pal_authored`, and
then blacks out the entries it intends to fade in. **The snapshot must therefore
happen before the blackout, and both before `_palette.show`** — snapshot it after
and every fade runs from black to black, so the title and the nebula never appear.

```
    ldd   #Pal_black / PalUpdateNow      ; screen black before anything
    _gameMode.init                       ; LoadAct: blits the nebula into both pages
    BandSave band_text / band_msg / BallsSnapshot   ; the pristine moment
    _gfxlock.init
    ScenarioInit                         ; 1. snapshot the AUTHORED colours
                                         ; 2. black out groups {3} and {2,7-15}
                                         ; 3. arm the first script step
    _palette.set #Pal_starfield
    _palette.show                        ; commits a palette that is black but for
                                         ;   1 (unused: byfx inert) and 4/5/6
                                         ;   (unused: sf_active = 0)
```

**`ScenarioInit` must also be cheap.** An earlier version spent ~0.4s here
building the fade ramp and the machine never reached the first frame. Init is not
a free place to think.

## Components

| File | Change |
|---|---|
| `global/scenario.asm` | **new** — script table, the tick, `pal_scaled`, group fades |
| `global/band.asm` | **new** — generalises `textband.asm` onto a descriptor |
| `global/textband.asm` | **deleted** — becomes a `band.asm` descriptor |
| `global/starfield.asm` | round-robin layer init; `sf_active` bounds both loops |
| `objects/byfx/byfx.asm` | two gates; `FADE_TICKS` 16 → 10 |
| `objects/title/title.asm` | also draws `sc_msg`, centred from its own length |
| `global/balls.asm` | `sc_balls_on` gate |
| `game-mode/00/main.asm` | wiring; `UserIRQ` music gate |

## Captions cost no new object page

`fnt_4x6_shd` hard-codes palette index 3 — the title's colour, already lit by the
time any caption appears. So the title object becomes "the colour-3 text object":
it draws its fixed title plus whatever `sc_msg` points at. A separate caption
object would have to carry its own copy of `DrawText` and the ~5.7 Kb font in its
own banked page, because a font does not fit twice in one 16 Kb page. Reusing the
title's page costs nothing.

Verified: glyph 07 (ASCII 39, apostrophe) exists in `3x5_shaded`, so
`LET'S ADD MORE STARS` renders. Both captions are upper-case, which the font
covers.

## Caption erase — the textband problem again

A caption drawn over the still-black nebula overwrites nebula pixels. Those
pixels would be invisible while the nebula is black and then appear as permanent
black holes the moment it fades in at t=31s. Save-under cannot fix it (it would
sample stars and captions as "background" — the failure already documented in
`textband.asm`).

Same solution as the text and the balls: snapshot the pristine nebula under the
caption band once at init, restore it every frame before `StarfieldRender`.
Restoring unconditionally every frame — rather than only on caption change — costs
one memcpy and removes the entire class of "who is dirty" bugs, and it is what
`textband.asm` already does.

Since this is the second instance of that routine, `textband.asm` and the caption
band collapse into one `band.asm` driven by a descriptor:

```
bd_col0  equ 0      ; byte, first byte column
bd_ncol  equ 1      ; byte, byte columns (EVEN: copied as words)
bd_row0  equ 2      ; byte, first row
bd_nrow  equ 3      ; byte, rows
bd_buf   equ 4      ; word, snapshot buffer
bd_size  equ 6
```

with `BandSave` / `BandRestore` taking X = descriptor. The balls keep their own
routine: they restore eight small moving boxes, not one fixed rectangle.

**Ordering is load-bearing** and unchanged from `textband.asm`: every band restore
must precede `StarfieldRender`, because the star plot decides "is a star already
here?" by testing a nibble against 4..6, and that test is only honest if last
frame's overdraw is gone.

Caption geometry: measured across all 96 glyphs rather than assumed —
`fnt_4x6_shd` spans exactly **7 rows** from `DrawText_pos` and every write is
row-aligned. Band = rows 140..146, byte columns 2..37 (36, even) = 504 bytes.
Clear of the title (88) and the "by FX" band (98..108).

Captions **centre themselves**: the title object measures the string and starts it
at byte column `(40 - length) / 2`, so a new caption is centred by writing it and
nothing else. A centred caption of length L occupies columns `(40-L)/2` ..
`(40+L)/2-1`, so the band covers every caption up to 36 glyphs — exactly the
longest one.

## Star ramp

`star_data` is currently three contiguous 24-star layer blocks, so a plain
`sf_active` count would fill the field slow-layer-first and no parallax would be
visible until the last third of the ramp. `StarfieldInit` is reordered to
round-robin the layers so every count is balanced across all three speeds.

The order is `[fast, slow, mid]` repeating, which also puts the **white fast star
(layer 2, colour 6, 3 px/frame)** at index 0 — that is the lone star of t=6s. It
crosses in 1.07s, so ~9 crossings in its 10 seconds, and colour 6 (`$FFF`) is the
only star colour genuinely legible alone on black (colour 4 is `$444`).

`sf_active` ramps 1 → 72 in 8.8 fixed point over 250 frames, driven by
`gfxlock.frameDrop.count` like every other motion in this mode.

New stars pop in at their seeded x rather than streaming in from the right edge.
At ~14 single pixels per second this reads as the field densifying; spawning them
all at x=159 would instead read as a wave sweeping left. It also keeps the hot
loop untouched.

Both loops are bounded by a precomputed `sf_active_end` pointer rather than
multiplying `sf_active * st_size` every frame.

## "by FX" — its 3s fade is already written

The object already ping-pongs colour 1 from level 0. `FADE_TICKS 16 → 10` makes
one direction 15 x 10/50 = 3s, so "fades in over 3 seconds" and "then animates its
palette forever" are the same mechanism, correctly tuned — not two features.

When `sc_osc_on` fires, the oscillation phase starts at **25**, where
`osc_x[25] = 70`: 2 px from the object's resting x=68 (invisible) and moving
**right**, which is the requested direction.

## Timeline

Durations in 50Hz frames, ticked by `gfxlock.frameDrop.count`.

| # | t | dur | Action | Mechanism |
|---|---|---|---|---|
| 0 | 0s | 3s | title fades in | ramp group {3} 0→16 |
| 1 | 3s | 3s | music starts; "by FX" fades in | `sc_byfx_on`; object's ping-pong |
| 2 | 6s | 10s | one white fast star, right→left, ~9 crossings | `sf_active = 1` |
| 3 | 16s | 5s | `THIS WAS THE ONE STAR STARFIELD DEMO` | `sc_msg` |
| 4 | 21s | 5s | caption → `LET'S ADD MORE STARS`; stars ramp 1→72 | `sc_msg`; `sf_active` ramp |
| 5 | 26s | 5s | caption gone; "by FX" starts oscillating rightward | `sc_msg=0`; `sc_osc_on` |
| 6 | 31s | 3s | nebula + xenon fade in | ramp group {2, 7–15} 0→16 |
| 7 | 34s | 5s | hold | — |
| 8 | 39s | ∞ | balls appear and orbit | `sc_balls_on` |

The end state holds: field scrolling, "by FX" ping-ponging and oscillating, balls
turning, music looping. Nothing tears down and the scenario does not loop.

## Budget

RAM: `pal_scaled` 272 + `pal_authored` 32 + caption band 504 + script and state
~100 ≈ 900 bytes. Measured after the fact: the main engine is 13093 bytes, ending
at `$9424`, leaving **3035 bytes free**. No new object page.

CPU: two memcpys and a script tick per frame, against the ~3500 cycles the balls
already spend out of ~40000 available at the loop's ~25Hz.

## Verification

Boot the floppy in TOJE (`run_frames` only — `run_until_pc` over ~1M instructions
desyncs the machine and reports false negatives).

- **Per phase**: screenshot at the midpoint of each of the 9 steps and assert what
  is visible. Assert what is *not* visible too: at t=10s exactly one star colour
  may be present and every nebula entry must still read black.
- **Palette, not pixels**: read `Pal_starfield` directly at phase boundaries. The
  nebula entries must be `$0000` until t=31s and reach their authored values by
  t=34s. This distinguishes "faded correctly" from "drawn correctly".
- **The caption band leaves no scar**: this is the one that matters. Screenshot at
  t=38s, after the captions are long gone and the nebula is fully lit, and diff the
  caption band against the same rows of a build with the scenario's captions
  disabled. Any difference is a black hole punched by a caption.
- **Histogram conservation** over 3000+ frames in the end state, as for the balls:
  no colour may grow. This is the check that caught the signed-offset bug in the
  text oscillation, which a visual crop had missed.

## Traps found while building this

- **`fdb 150 : fcb SC_FADE : fdb x : fcb 27` assembles WITHOUT error and emits
  only the first `fdb`**, silently truncating each 6-byte script entry to 2. lwasm
  treats `:` and everything after it as a comment. One directive per line. Same
  class of trap as `RMB`, and just as silent — catch it by asserting the table's
  span in the symbol map (`sc_step - scenario_script` must equal `13 * 6`).
- **`@local` labels are scoped to the enclosing global label.** Shared scratch
  used by two routines (`band_ncol`, `pal_lvl`) must be a global label, or each
  routine silently gets its own copy.
- **`beq` is ±127 bytes.** A zero-guard branching to an `rts` at the far end of
  `StarfieldRender` overflows; invert the test and put the `rts` inline instead.
- **`fcb 1, 3` (space after the comma) is a "Bad expression"** — the codebase's
  `fcb` lists never have spaces.

## Verification notes

- **PC is not a liveness signal.** `run_frames` stops wherever it lands, and
  `$FAxx`/`$FBxx`/`$E830` is the ROM's *interrupt handler* — reached 50x/s on a
  perfectly healthy machine. Half a day went into a phantom crash diagnosed from
  `pc:"FB18"`. Use `dump_trace_ring` (engine addresses in the ring = the loop is
  running) or assert on state via `read_memory`.
- **A correct black screen is indistinguishable from a crashed one** — which is
  exactly what this scenario opens with. Assert on the palette, never on "the
  screenshot is black".
- **Never diagnose from registers after `step`.** Post-`step` reads showed
  `X=Y=U=$CCCC` — textbook runaway — on a build that ran fine under plain
  `run_frames`.
