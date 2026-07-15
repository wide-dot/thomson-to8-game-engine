# Starfield Scripted Scenario Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn the starfield mode into a ~39s scripted intro: black screen → title fade → music + "by FX" → one star → two captions → the field filling up → nebula reveal → balls.

**Architecture:** A single `scenario.asm` ticks a script table off `gfxlock.frameDrop.count` and writes five gate variables. Every other module reads a gate and stays dumb. Most of the sequence is a palette schedule, because `LoadAct` already blits the nebula into both pages at init and the title already draws itself from frame 0 — they are invisible only because their palette entries are black.

**Tech Stack:** 6809 assembly, LWASM, wide-dot TO8 engine, TOJE emulator (MCP) for verification.

**Spec:** `docs/superpowers/specs/2026-07-15-starfield-scenario-design.md`

## Global Constraints

- **Never use `RMB`.** This assembles into a RAW binary loaded contiguously at `$6100`. `RMB` advances the location counter but emits no bytes, so everything after it lands one address early at runtime and silently skips the first opcode of later routines. Reserve with `fcb` / `fdb` / `fill`.
- **Accumulator-offset indexing is SIGNED.** `LDA B,X` treats B as a signed offset. Any table index that can reach 128 must be loaded via D (`clra` + `lda d,x`). This bug already shipped once here.
- **BM16 planes are inverted in data space:** RAM A at `$C000`, RAM B at `$A000`. `byte offset = y*40 + (x>>2)`; plane = RAM B if `(x AND 2)`; nibble = low if `(x AND 1)`.
- **All motion is compensated by `gfxlock.frameDrop.count`**, never by one step per call. The render loop settles at ~25Hz but drops frames.
- **Every band restore must precede `StarfieldRender`**, because the star plot decides "is a star already here?" by testing a nibble against 4..6, and that test is only honest if last frame's overdraw is gone.
- **Star colours 4/5/6 must stay disjoint from the nebula's** (0, 2, 7-15), for the same reason.
- **Font geometry (measured, do not re-derive):** `fnt_4x6_shd` hard-codes palette index 3, advances 1 byte column (4 px) per glyph, and spans **7 rows (0..6)** from `DrawText_pos`. All writes are row-aligned.
- **Build:** `cd game-projects/starfield && ./build-linux.sh`. Output `dist/starfield.fd`.
- **Boot recipe:** `mount_disk dist/starfield.fd` → `reset` → `run_frames 150` → `type_keys ["0F"]` → `run_frames N`. Use **`run_frames` only** — `run_until_pc` over ~1M instructions desyncs the machine and reports false negatives (screenshots show nothing drawn even when the build is correct).
- **Symbols:** after a build, addresses are in `generated-code/starfield/FD/main.lwmap` (`grep 'Symbol: <name> '`).
- **50Hz frames per second = 50.** All durations in the script are in 50Hz frames.

---

## File Structure

| File | Responsibility |
|---|---|
| `global/band.asm` | **new.** Generic pristine-nebula band save/restore driven by a descriptor. Replaces `textband.asm`. Owns no geometry. |
| `global/scenario.asm` | **new.** Script table, the tick, gate variables, `PalRampBuild`, group fades. The only writer of gates. |
| `global/starfield.asm` | round-robin layer seeding; `sf_active` bounds both loops |
| `global/balls.asm` | `sc_balls_on` gate |
| `objects/byfx/byfx.asm` | `sc_byfx_on` / `sc_osc_on` gates; `FADE_TICKS` 16 → 10 |
| `objects/title/title.asm` | draws the fixed title **and** `sc_msg` |
| `game-mode/00/main.asm` | wiring; `UserIRQ` music gate |
| `global/textband.asm` | **deleted** — becomes a `band.asm` descriptor |

Gate ownership is the invariant that keeps this decomposable: `scenario.asm` writes, everyone else reads. No module ever writes another's gate.

---

### Task 1: `band.asm` — generalise the pristine-band restore

`textband.asm` already does exactly the right thing for one fixed rectangle. The captions need a second one. Rather than clone forty lines, lift the geometry into a descriptor.

**Files:**
- Create: `game-projects/starfield/global/band.asm`
- Delete: `game-projects/starfield/global/textband.asm`
- Modify: `game-projects/starfield/game-mode/00/main.asm`

**Interfaces:**
- Produces: `BandSave` (in: X = descriptor; clobbers A,B,D,X,U), `BandRestore` (same), and the descriptor layout below.

```asm
bd_col0  equ 0      ; byte, first byte column (0..39)
bd_ncol  equ 1      ; byte, byte columns — MUST BE EVEN (copied as words)
bd_row0  equ 2      ; byte, first row (0..199)
bd_nrow  equ 3      ; byte, rows
bd_buf   equ 4      ; word, snapshot buffer: nrow*ncol for RAM A, then the same for RAM B
bd_size  equ 6
```

- [ ] **Step 1: Write `band.asm`**

Port `TextBandSave` / `TextBandRestore` verbatim, replacing the `TB_*` equates with reads through X. Keep the existing header's reasoning (why save-under is wrong here; why the order is load-bearing) — it applies unchanged and is the most valuable thing in that file. The VRAM address is `$C000 + bd_row0*40 + bd_col0`; RAM B is the same offset at `-$2000`; the buffer's RAM B half starts at `bd_nrow*bd_ncol`.

- [ ] **Step 2: Add the by-FX descriptor**

Same geometry as the current `TB_*` constants, so this is a pure refactor:

```asm
band_text  fcb 11,18,98,11        ; col0, ncol, row0, nrow  (by FX: x 44..115, y 98..108)
           fdb band_text_data
band_text_data fill 0,18*11*2
```

- [ ] **Step 3: Rewire `main.asm`**

`jsr TextBandSave` → `ldx #band_text` / `jsr BandSave`. Same for restore. Replace the `textband.asm` INCLUDE with `band.asm`. Delete `textband.asm`.

- [ ] **Step 4: Build**

Run: `cd game-projects/starfield && ./build-linux.sh 2>&1 | tail -3`
Expected: `Build done !`, no assembler errors.

- [ ] **Step 5: Verify no regression — by FX still leaves no smear**

This is a refactor, so the bar is "identical behaviour". Boot, run 3000 frames, and count colour-1 pixels. Colour 1 is owned exclusively by "by FX", so its pixel count is a smear detector: a fade changes the *colour*, never the *count*.

Run: boot recipe, `run_frames 3000`, screenshot, then count pixels of the palette-1 RGB.
Expected: **35 BM16 pixels**, bounding box x 368..443 / y 312..321 in screen coords — the numbers the pre-refactor build produces. Any growth means the band is mis-sized.

- [ ] **Step 6: Commit**

```bash
git add game-projects/starfield/global/band.asm game-projects/starfield/game-mode/00/main.asm
git rm game-projects/starfield/global/textband.asm
git commit -m "refactor(starfield): lift the pristine-band restore onto a descriptor"
```

---

### Task 2: Caption band + captions in the title object

**Files:**
- Modify: `game-projects/starfield/objects/title/title.asm`
- Modify: `game-projects/starfield/global/band.asm` (add the caption descriptor)
- Modify: `game-projects/starfield/game-mode/00/main.asm`

**Interfaces:**
- Consumes: `BandSave` / `BandRestore` / descriptor layout (Task 1).
- Produces: `sc_msg` (word, 0 = no caption) — declared here temporarily as `fdb 0` in `title.asm`'s reader; **moves to `scenario.asm` in Task 6.** Also `band_msg` descriptor.

- [ ] **Step 1: Add the caption descriptor to `band.asm`**

Geometry is measured, not guessed: 36 chars × 4 px = 144 px at x=8 → byte columns 2..37 (36, even). The font spans 7 rows from y=140 → rows 140..146. Clear of the title (88) and the by-FX band (98..108).

```asm
band_msg  fcb 2,36,140,7          ; col0, ncol, row0, nrow
          fdb band_msg_data
band_msg_data fill 0,36*7*2       ; 504 bytes
```

- [ ] **Step 2: Draw `sc_msg` from `title.asm`**

After the existing title `DrawText`, add:

```asm
        ldd   sc_msg
        beq   @nomsg
        tfr   d,y                      ; Y = caption text
        ldd   #$C000+MSG_ROW*40+MSG_COL
        std   DrawText_pos
        ldx   #fnt_4x6_shd             ; colour 3 — same font, already in this page
        jsr   DrawText
@nomsg
```

`MSG_ROW equ 140`, `MSG_COL equ 2`. The font and `DrawText` are already included in this object's page — that is the whole reason captions live here rather than in an object of their own.

- [ ] **Step 3: Wire the band into `main.asm`**

`ldx #band_msg` / `jsr BandSave` next to the existing `BandSave`, in the pristine window right after `_gameMode.init`. And `ldx #band_msg` / `jsr BandRestore` in `MainLoop`, before `StarfieldRender`, next to the by-FX restore.

- [ ] **Step 4: Hardcode a caption and build**

Temporarily seed `sc_msg fdb txt_msg1` with `txt_msg1 fcc "THIS WAS THE ONE STAR STARFIELD DEMO" / fcb 0`.

Run: `./build-linux.sh 2>&1 | tail -3`
Expected: `Build done !`

- [ ] **Step 5: Verify the caption renders**

Boot, `run_frames 400`, screenshot, crop rows 140..146.
Expected: the caption legible in colour 3 (yellow, `$ff00`), 36 glyphs wide starting at byte column 2.

- [ ] **Step 6: Verify the caption leaves no scar — the load-bearing check**

This is the failure the band exists to prevent, so test it directly. Write `sc_msg = 0` into RAM live via `write_memory` (address from `main.lwmap`), run 4 more frames (2 renders = both pages), and screenshot.

Expected: rows 140..146 return to **pure nebula**, identical to a build that never drew a caption. Any residue is a black hole that would become visible at the t=31s nebula reveal.

- [ ] **Step 7: Commit**

```bash
git add game-projects/starfield/global/band.asm game-projects/starfield/objects/title/title.asm game-projects/starfield/game-mode/00/main.asm
git commit -m "feat(starfield): draw scenario captions from the title object's page"
```

---

### Task 3: `sf_active` — the star count becomes a variable

**Files:**
- Modify: `game-projects/starfield/global/starfield.asm`

**Interfaces:**
- Produces: `sf_active` (byte, 0..72), `sf_active_end` (word, `star_data + sf_active*st_size`), `SetActiveStars` (in: A = count; recomputes `sf_active_end`; clobbers A,B,D,X).

- [ ] **Step 1: Round-robin the layer seeding**

`StarfieldInit` currently seeds three contiguous 24-star blocks, so a plain count would fill the field slow-layer-first and show no parallax until the last third of the ramp. Reorder so index `i` takes layer `sf_order[i mod 3]`:

```asm
* Layer order is [fast, slow, mid] repeating, NOT 0,1,2. Two reasons, both
* load-bearing:
*   - round-robin (rather than three contiguous blocks) keeps every value of
*     sf_active balanced across all three speeds, so the ramp shows parallax
*     from its first stars instead of filling slow-layer-first;
*   - starting on the FAST layer puts the white 3px/frame star at index 0, and
*     index 0 is the lone star of the scenario's t=6s phase. Colour 6 ($FFF) is
*     the only star colour legible alone on black — colour 4 is $444.
sf_order  fcb 2,0,1
```

Restructure the init loop to walk `i` 0..NUM_STARS-1, deriving the layer from `sf_order[i mod 3]` instead of the current outer layer loop. Keep everything else (RNG seeding, `st_row` caching, both pre-shifted colour forms) identical.

- [ ] **Step 2: Bound both loops by `sf_active_end`**

```asm
sf_active     fcb 0
sf_active_end fdb star_data        ; = star_data + sf_active*st_size

SetActiveStars                     ; A = count
        sta   sf_active
        ldb   #st_size
        mul                        ; D = count * 9  (max 72*9 = 648, fits)
        addd  #star_data
        std   sf_active_end
        rts
```

In `StarfieldUpdate` and `StarfieldRender`, replace `cmpu #star_data+NUM_STARS*st_size` with `cmpu sf_active_end`. **Both loops must also early-out when `sf_active = 0`**, because they are do-while: with `sf_active_end == star_data` the first iteration would run before the bound is tested and would move and plot star 0.

Inactive stars keep `er_addr = 0`, so the erase pass already skips them — no extra work needed for the ramp.

- [ ] **Step 3: Build**

Run: `./build-linux.sh 2>&1 | tail -3`
Expected: `Build done !`

- [ ] **Step 4: Verify sf_active = 0 draws nothing**

`StarfieldInit` leaves `sf_active = 0`. Boot, `run_frames 400`, screenshot.
Expected: **zero** pixels of colours 4, 5 or 6 anywhere on screen. (The nebula cannot supply them — `img2to8.py` reserves those three slots.) This is what makes the black opening possible.

- [ ] **Step 5: Verify sf_active = 1 gives exactly one white fast star**

`write_memory` `sf_active`, then call `SetActiveStars`… simpler: write `sf_active_end = star_data + 9` directly. Run 2 frames, screenshot; run 2 more, screenshot.

Expected: exactly **1** pixel of colour 6 (`$FFF` white), zero of colours 4 and 5, and it moves **−3 px per 50Hz frame** (−6 px per render at 25Hz), leftward.

- [ ] **Step 6: Verify sf_active = 72 reproduces today's field**

Write `sf_active_end = star_data + 648`, run 400 frames, screenshot.
Expected: **72 star pixels**, split 24/24/24 across colours 4/5/6 — the round-robin must not have changed the per-layer totals.

- [ ] **Step 7: Commit**

```bash
git add game-projects/starfield/global/starfield.asm
git commit -m "feat(starfield): make the star count a runtime variable"
```

---

### Task 4: "by FX" gates

**Files:**
- Modify: `game-projects/starfield/objects/byfx/byfx.asm`

**Interfaces:**
- Consumes: `sc_byfx_on` (byte flag), `sc_osc_on` (byte flag) — declared in `scenario.asm` (Task 6); stub them as `fcb 0` in `main.asm`'s RAM until then.

- [ ] **Step 1: `FADE_TICKS` 16 → 10**

The object already ping-pongs colour 1 from level 0, so the requested "fade in over 3s, then animate forever" is the mechanism it already has, merely mistuned. 15 steps × 10 frames / 50 = **3.0s** per direction. Update the header comment: the 4.8s figure and its reasoning are now wrong.

- [ ] **Step 2: Gate `Init` on `sc_byfx_on`**

```asm
Init
        lda   sc_byfx_on
        beq   @rts                 ; inert until the scenario starts the music
        clr   o_level,u            ; start invisible, fading in
        ...
        lda   #1
        sta   routine,u            ; next frame -> Live
@rts    rts
```

While inert the object draws nothing, so palette entry 1 may sit at its authored cyan without showing anything. That is why the scenario does not need to zero entry 1.

- [ ] **Step 3: Gate the oscillation on `sc_osc_on`**

Replace the unconditional oscillation block with:

```asm
        lda   sc_osc_on
        bne   @osc
        ldd   #68                  ; resting x, matches main.asm's seed
        std   x_pos,u
        bra   @drawpos
@osc
        ldb   o_osc,u
        ...                        ; existing table walk, unchanged
@drawpos
```

`Init` seeds `o_osc` to **25**, not 0: `osc_x[25] = 70`, which is 2 px from the resting x=68 (invisible) and moving **rightward** — the requested direction. Starting at phase 0 would snap 18 px left the instant the gate opens.

Keep the `clra` + `lda d,x` indexing. It is not currently reachable at OSC_LEN=100, but it is one edit from being so, and it has already shipped as a bug once.

- [ ] **Step 4: Build and verify the gates**

Run: `./build-linux.sh 2>&1 | tail -3`, then boot and `run_frames 400`.
Expected with both gates 0: **zero** pixels of colour 1 on screen.

Then `write_memory sc_byfx_on = 1`, `run_frames 200`.
Expected: "by FX" visible, static at x=68, its colour ramping.

Then `write_memory sc_osc_on = 1`, screenshot every 25 frames for 100.
Expected: x sweeps 50..90 and **starts by moving right**.

- [ ] **Step 5: Commit**

```bash
git add game-projects/starfield/objects/byfx/byfx.asm
git commit -m "feat(starfield): gate the by-FX object on the scenario"
```

---

### Task 5: Balls gate and music gate

**Files:**
- Modify: `game-projects/starfield/global/balls.asm`
- Modify: `game-projects/starfield/game-mode/00/main.asm`

**Interfaces:**
- Consumes: `sc_balls_on`, `sc_music_on` (byte flags).

- [ ] **Step 1: Gate the balls**

The balls own no palette slot — they borrow 2, 9, 11, 4, 5, 6 — so there is no entry to keep black and the gate must suppress the drawing. Early-out both `BallsDraw` and `BallsRestore` on `sc_balls_on == 0`.

`BallsUpdate` stays **ungated**: the phase is wall-clock and costs nothing, and gating it would make the balls appear at a stale phase. Note this in the file.

- [ ] **Step 2: Gate the music ticks in `UserIRQ`**

`_music.init.*` calls stay at init — they only set up player state, and moving them into the script would mean initialising a music player from inside the render loop. Gate only the per-frame ticks; a player that is never ticked emits nothing.

```asm
UserIRQ
        jsr   gfxlock.bufferSwap.check
        jsr   PalUpdateNow             ; commits the fades
        lda   sc_music_on
        beq   @nomusic
        jsr   YVGM_MusicFrame          ; YM2413 tick
        jmp   vgc_update               ; SN76489 tick (returns for us)
@nomusic
        rts
```

Note the structure: `vgc_update` must stay the last thing reached by `jmp`, because it returns on our behalf. The `@nomusic` path therefore needs its own `rts`.

- [ ] **Step 3: Build and verify**

Run: `./build-linux.sh 2>&1 | tail -3`, boot, `run_frames 400`.
Expected: no balls on screen; `balls_phase` **still advancing** (read it twice 50 frames apart — it must differ, proving `BallsUpdate` stayed ungated).

Then `write_memory sc_balls_on = 1`, `run_frames 10`.
Expected: 8 balls appear in a ring at the current phase, not at phase 0.

- [ ] **Step 4: Commit**

```bash
git add game-projects/starfield/global/balls.asm game-projects/starfield/game-mode/00/main.asm
git commit -m "feat(starfield): gate the balls and the music ticks"
```

---

### Task 6: `scenario.asm` — palette ramp and group fades

**Files:**
- Create: `game-projects/starfield/global/scenario.asm`
- Modify: `game-projects/starfield/game-mode/00/main.asm`

**Interfaces:**
- Produces: all gates (`sc_music_on`, `sc_byfx_on`, `sc_osc_on`, `sc_msg`, `sc_balls_on`), `ScenarioInit`, `PalRampBuild`, `PalGroupSet` (in: X = group mask table, B = level 0..16).

- [ ] **Step 1: `to8RGB` and `pal_ramp`**

```asm
* The EF9369 DAC ladder. Entry k of a palette is an INDEX into this, not a
* brightness — and the ladder's first step jumps straight to 97/255 (38%).
to8RGB  fcb 0,97,122,143,158,171,184,194,204,212,219,227,235,242,250,255

* 17 levels (0..16) x 16 entries x 2 bytes. Fading a group to level L is a byte
* copy of that group's entries out of pal_ramp+L*32 — no arithmetic per step.
pal_ramp fill 0,17*32
```

- [ ] **Step 2: `PalRampBuild`**

For each level L 0..16, each entry 0..15, each channel: `want = to8RGB[target_index] * L / 16`, then match `want` back to the nearest ladder index by a 16-entry scan, and pack.

The scaling happens in **RGB space, not index space**. Scaling the index linearly would put a target of 15 at index 7 (=194, i.e. 76% brightness) by the halfway point — the fade would arrive almost entirely in its first few steps and then crawl.

Palette entry format is `$GR0B`: byte0 = `G<<4 | R`, byte1 = `000M BBBB`. Level 16 must reproduce the authored entry **exactly** (`want = to8RGB[t]*16/16 = to8RGB[t]` → scan finds `t`); assert this in Step 5.

Reads the authored `Pal_starfield`. Built at runtime rather than by a `gen-palfade.py` deliberately: a tool would have to re-implement the java builder's palette index convention, and that convention has already caused one bug here (`PngToBottomUpB16Bin` emits `pixels[i] - 1`, so PNG index k is engine colour k-1). Deriving from `Pal_starfield` means the ramp cannot drift out of sync with the palette, because it *is* the palette.

- [ ] **Step 3: `PalGroupSet` and the group tables**

```asm
* Groups are lists of palette entry indices, count-prefixed.
pal_grp_title  fcb 1, 3
pal_grp_neb    fcb 11, 2,7,8,9,10,11,12,13,14,15
```

`PalGroupSet` (X = group, B = level): for each entry in the group, copy its 2 bytes from `pal_ramp + level*32 + entry*2` into `Pal_starfield + entry*2`, then `clr PalRefresh` to arm the commit. `PalUpdateNow` runs from `UserIRQ`; do not call it here.

- [ ] **Step 4: `ScenarioInit`**

**Ordering is load-bearing:** build the ramp from the authored palette, *then* zero the groups. Build it after the zeroing and the ramp is derived from a palette that is already black — the title and the nebula would fade from black to black and never appear.

```asm
ScenarioInit
        jsr   PalRampBuild             ; 1. reads the AUTHORED Pal_starfield
        ldx   #pal_grp_title           ; 2. now black them out
        clrb
        jsr   PalGroupSet
        ldx   #pal_grp_neb
        clrb
        jsr   PalGroupSet
        ; gates all start at 0 from their fcb declarations
        rts
```

In `main.asm`, call `ScenarioInit` after `_gfxlock.init` and **before** `_palette.set` / `_palette.show`.

- [ ] **Step 5: Build and verify the ramp numerically**

This is the step that catches a wrong ramp before it becomes a visual mystery. Boot, `run_frames 400`, then `read_memory` `pal_ramp`.

Expected, with the authored palette (`0:$0000  1:$f00f  2:$0002  3:$ff00  4:$4404  5:$aa0a`):
- `pal_ramp + 0*32` (level 0) = **all zeroes**, 32 bytes.
- `pal_ramp + 16*32` (level 16) = **byte-identical to the authored `Pal_starfield`** — every entry round-trips.
- `pal_ramp + 8*32`, entry 3 (offset +6): target `$ff00` is G=15,R=15,B=0 → `to8RGB[15]=255`, half = 127 → nearest ladder entry is index **2** (122; |127-122|=5 beats index 3's 143 at 16) → `$220 0` = bytes `$22,$00`. Gamma-correct, not `$88,$00`.

Also `read_memory Pal_starfield`: entries 3 and 2,7..15 must be `$0000`; entry 1 must still be `$f00f` (byfx is inert, so it shows nothing).

- [ ] **Step 6: Verify a fade visually**

`write_memory` a call is awkward; instead temporarily hardcode `ldb #16` for the title group in `ScenarioInit`, rebuild, boot.
Expected: the title visible at its authored yellow, the nebula still fully black. Revert the hardcode.

- [ ] **Step 7: Commit**

```bash
git add game-projects/starfield/global/scenario.asm game-projects/starfield/game-mode/00/main.asm
git commit -m "feat(starfield): gamma-correct palette ramp and group fades"
```

---

### Task 7: The script table

**Files:**
- Modify: `game-projects/starfield/global/scenario.asm`
- Modify: `game-projects/starfield/game-mode/00/main.asm`

**Interfaces:**
- Produces: `ScenarioTick` (call once per render from `MainLoop`, inside the gfxlock bracket; clobbers A,B,D,X,Y,U).

- [ ] **Step 1: Script format**

Each step: a duration in 50Hz frames, an action opcode, and a word operand. The tick burns down the duration by `gfxlock.frameDrop.count` and fires the action on entry to each step. Two actions are *continuous* (they run every frame for the step's duration) rather than one-shot: `FADE` and `RAMP`.

```asm
sc_step   fcb 0            ; index into the script
sc_left   fdb 0            ; 50Hz frames remaining in this step
sc_fx     fdb 0            ; 8.8 accumulator for FADE level / RAMP count
sc_rate   fdb 0            ; 8.8 increment per 50Hz frame for the above

* op            operand
SC_FADE   equ 0            ; word: group table ptr — ramp level 0->16 over the step
SC_STARS  equ 1            ; word: count — SetActiveStars, immediate
SC_RAMP   equ 2            ; word: target count — sf_active 1->target over the step
SC_MSG    equ 3            ; word: text ptr (0 = none)
SC_FLAG   equ 4            ; word: hi = flag address low byte... (see step 2)
SC_END    equ 5            ; hold forever
```

- [ ] **Step 2: The table**

```asm
* dur (50Hz frames), op, operand
scenario_script
        fcb   150 : fcb SC_FADE  : fdb pal_grp_title    ; 0s  title fades in, 3s
        fcb   0   : fcb SC_FLAG  : fdb sc_music_on      ; 3s  music starts
        fcb   0   : fcb SC_FLAG  : fdb sc_byfx_on       ;     by FX fades in (3s, its own ramp)
        fcb   150 : fcb SC_NOP   : fdb 0                ;     ...wait it out
        fcb   250 : fcb SC_STARS : fdb 1                ; 6s  one white fast star, 10s
        fcb   250 : fcb SC_MSG   : fdb txt_msg1         ; 16s "THIS WAS THE ONE STAR..."
        fcb   250 : fcb SC_MSG   : fdb txt_msg2         ; 21s "LET'S ADD MORE STARS"
        fcb   0   : fcb SC_RAMP  : fdb 72               ;     ...and the field fills, 5s
        fcb   0   : fcb SC_MSG   : fdb 0                ; 26s caption gone
        fcb   250 : fcb SC_FLAG  : fdb sc_osc_on        ;     by FX starts oscillating, 5s
        fcb   150 : fcb SC_FADE  : fdb pal_grp_neb      ; 31s nebula + xenon fade in, 3s
        fcb   250 : fcb SC_NOP   : fdb 0                ; 34s hold, 5s
        fcb   0   : fcb SC_FLAG  : fdb sc_balls_on      ; 39s balls appear
        fcb   0   : fcb SC_END   : fdb 0                ;     hold forever

txt_msg1 fcc "THIS WAS THE ONE STAR STARFIELD DEMO"
         fcb 0
txt_msg2 fcc "LET'S ADD MORE STARS"
         fcb 0
```

A duration of 0 means "fire and fall through to the next step this same frame", which is how several actions land on one instant. `SC_RAMP` at 21s attaches to the *previous* step's remaining duration — simpler: give `SC_RAMP` its own 250 and make the `SC_MSG txt_msg2` step 0-duration. Resolve to whichever reads cleaner while keeping the timeline in the spec exact.

**The tick must loop on zero-duration steps**, not process one step per frame, or the 0-duration entries would each cost a frame and the timeline would drift.

`txt_msg2` contains an apostrophe: glyph 07 (ASCII 39) exists in `3x5_shaded` and was verified to render.

- [ ] **Step 3: `ScenarioTick`**

Burn `sc_left` down by `gfxlock.frameDrop.count`. Advance continuous actions (`SC_FADE`, `SC_RAMP`) by `sc_rate * frameDrop.count` in 8.8 and apply them every frame. On reaching 0, advance `sc_step`, fire the new step's action, and loop while the new step's duration is 0.

On entering a `SC_FADE`/`SC_RAMP` step, set `sc_rate = (span << 8) / duration` so the effect exactly fills the step: `span = 16` for a fade, `71` for the ramp. Compute at build time and store per-step if the division is awkward — the values are constants (`16*256/150 = 27`, `71*256/250 = 72`).

Clamp on the last frame: write level **16** and count **72** exactly on step exit, so a rounding shortfall cannot leave the nebula at 15/16 brightness forever.

- [ ] **Step 4: Wire into `main.asm`**

```asm
MainLoop
        _gfxlock.on
        jsr   ScenarioTick             ; FIRST: gates the rest of the frame
        ldx   #band_msg
        jsr   BandRestore              ; MUST precede StarfieldRender
        ldx   #band_text
        jsr   BandRestore              ; MUST precede StarfieldRender
        jsr   BallsRestore             ; MUST precede StarfieldRender
        jsr   BallsUpdate
        jsr   StarfieldUpdate
        jsr   StarfieldRender
        jsr   RunObjects               ; title + captions + byfx
        jsr   BallsDraw                ; LAST: in front of everything
        _gfxlock.off
        _gfxlock.loop
        bra   MainLoop
```

Remove the temporary `sc_msg` stub from `title.asm` and the gate stubs from `main.asm`; they now live in `scenario.asm`.

- [ ] **Step 5: Build**

Run: `./build-linux.sh 2>&1 | tail -3`
Expected: `Build done !`. Check the RAM budget line — the spec's estimate is ~1010 bytes against 4315 free.

- [ ] **Step 6: Verify each phase**

Boot once and screenshot at the midpoint of every step, asserting what is visible **and what is not**:

| t | frames | Expect visible | Expect absent |
|---|---|---|---|
| 1.5s | 75 | title, partially faded | everything else; colours 4/5/6 count = 0 |
| 4.5s | 225 | title full, by FX fading in | stars, nebula |
| 10s | 500 | 1 white star moving left | colours 4 and 5 count = 0; nebula black |
| 18s | 900 | caption 1 | still exactly 1 star |
| 23s | 1150 | caption 2, star count climbing | — |
| 28s | 1400 | 72 stars, by FX oscillating | **captions gone, no scar** |
| 32.5s | 1625 | nebula mid-fade | balls |
| 41s | 2050 | balls orbiting | — |

- [ ] **Step 7: Verify the palette schedule numerically**

Screenshots prove "drawn"; `read_memory Pal_starfield` proves "faded". Read it at t=30s and t=35s.
Expected: nebula entries (2, 7..15) **all `$0000`** at 30s, and **byte-identical to the authored values** at 35s. This distinguishes a fade bug from a draw bug.

- [ ] **Step 8: Verify no caption scar — the check the band exists for**

At t=41s the nebula is fully lit and the captions have been gone for 15s. Screenshot, then compare rows 140..146 against the same rows of a build with the `SC_MSG` steps removed.
Expected: **identical**. Any difference is a black hole punched by a caption and only revealed by the nebula fade.

- [ ] **Step 9: Verify the end state is durable**

`run_frames 3000` from t=41s, screenshot, compare colour histograms.
Expected: no colour grows. This is the check that caught the signed-offset bug in the text oscillation, which a visual crop had missed.

- [ ] **Step 10: Commit**

```bash
git add game-projects/starfield/global/scenario.asm game-projects/starfield/game-mode/00/main.asm game-projects/starfield/objects/title/title.asm
git commit -m "feat(starfield): drive the intro from a script table"
```

---

## Self-Review

**Spec coverage:** every spec section maps to a task — palette groups → T6; `pal_ramp` → T6; gates → T3/T4/T5/T6; silence before 3s → T5; init ordering → T6 S4; captions cost no page → T2; caption erase / `band.asm` → T1/T2; star ramp → T3/T7; by-FX 3s fade → T4; timeline → T7; verification → each task's verify steps plus T7 S6-S9.

**Placeholders:** one deliberate open choice in T7 S2 (where `SC_RAMP`'s 250 frames attach). Both spellings produce the spec's timeline; the constraint — the timeline must match the spec exactly — is stated.

**Type consistency:** `BandSave`/`BandRestore` take X = descriptor throughout. `sf_active`/`sf_active_end`/`SetActiveStars` named identically in T3 and T7. Gate names identical in T4/T5/T6/T7. `sc_msg` is declared in T2 as a stub and explicitly migrated in T7 S4.
