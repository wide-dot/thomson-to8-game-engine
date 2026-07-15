# Handoff — starfield music: move the mode to gfxlock + IRQ

**Date:** 2026-07-14
**Branch:** `starfield-music-wip` (commit `beace89e`) — builds and boots, but the screen stays black.
**Last known-good:** `main` @ `5a8bb158` — starfield + title + fading "by FX", no music. Works.

## The task

Move `game-projects/starfield/game-mode/00/main.asm` off the `WaitVBL` loop and onto
**gfxlock + a 50Hz IRQ**, with the music ticked from `UserIRQ` — the pattern goldorak and
r-type use. Then the music should play and the starfield keep rendering.

## Why

The music is already wired and builds, but with it playing `gfxlock.bufferSwap.count`
freezes (1–2 swaps over 160 frames): `WaitVBL` stops returning and nothing renders.
It is **not** a CPU budget problem — a full loop iteration costs only 4284 instructions.

The engine's own answer: `game-projects/goldorak/global/global-trailer-includes.asm`
**comments `WaitVBL.asm` out**, and `goldorak/game-mode/gamescreen/main.asm` runs
gfxlock + IRQ with the music in `UserIRQ`. Read that file first — it is the reference.

Ruled out already (don't redo):
- the sound engine never touches `$E7E7` (the register `WaitVBL` polls for the beam);
- `_SetCartPageA` writes `$E7E6` (cart space) only.

gfxlock was only ever broken here by the `rmb` bug (see below), which is now fixed, so it
should be viable. `gfxlock` also provides `gfxlock.backBuffer.id`, which the starfield's
per-page erase-lists index — so the starfield design survives the switch unchanged.

## Target shape (from goldorak/gamescreen/main.asm)

```asm
        _gameMode.init #GmID_starfield
        _gfxlock.init
        _music.init.SN76489 #Vgc_ingameSN,#MUSIC_LOOP,#0
        _music.init.YM2413  #Vgc_ingameYM,#MUSIC_LOOP,#0
        _music.init.IRQ #UserIRQ,#OUT_OF_SYNC_VBL,#Irq_one_frame
        _palette.set #Pal_starfield
        _palette.show
        jsr   StarfieldInit
        ; ... LoadObject_u for ObjID_title / ObjID_byfx ...
MainLoop
        jsr   RunObjects
        _gfxlock.on
        jsr   StarfieldUpdate
        jsr   StarfieldRender
        _gfxlock.off
        _gfxlock.loop
        bra   MainLoop

UserIRQ
        jsr   gfxlock.bufferSwap.check
        jsr   PalUpdateNow            ; commits the byfx fade
        jsr   YVGM_MusicFrame
        jmp   vgc_update              ; MUST be last and reached by jmp
```
Changes needed: drop `WaitVBL.asm` from the trailer, add `gfxlock.macro.asm`/`gfxlock.asm`,
re-add `_music.init.IRQ` to `global/global-macros.asm` (copy goldorak's), and move
`PalUpdateNow` + the music tick out of MainLoop into `UserIRQ`.

Careful: `_gfxlock.on` mounts the back buffer, so `StarfieldRender` must sit inside the
`on`/`off` bracket. `LoadAct`'s `ClearDataMem` stack-blasts and wants IRQs off — it runs
inside `_gameMode.init`, before `_music.init.IRQ`, so that ordering is already safe.

## Constraints that will bite you (all learned the hard way)

1. **Never `RMB` for data in this mode.** It is a RAW binary loaded contiguously at `$6100`;
   `RMB` advances the location counter but emits no bytes, so every later byte loads one
   address early and routines get entered one byte in (first opcode skipped). Use
   `fcb`/`fdb`/`fill 0,n`. Symptom: a symbol in `main.glb` is exactly 1 higher than where the
   real opcode sits in emulator memory. This is what broke the IRQ before (`jsr IrqInit`
   landed mid-instruction → `std TIMERPT` never ran).
2. **BM16 planes are inverted:** RAM B at `$A000`, RAM A at `$C000`. Pixel columns 0,1 →
   `$C000`; columns 2,3 → `$A000`. Offset `y*40 + (x>>2)`, nibble high if x even.
3. **The main engine must stay under 16Kb.** A font is ~96 compiled glyphs (~5.7Kb); two of
   them blew it. `DrawText` + font now live inside each text object's own banked page.
4. **A font variant IS a colour** — each compiled glyph hard-codes its palette index:
   `fnt_4x6_shd`→3, `fnt_4x6_shd_dis`→1, `fnt_4x6_shd_sel`→15. Stars deliberately sit on
   colours 4/5/6 so fading colour 1 touches only "by FX".
5. **Scroll speeds must be whole pixels/frame** — the renderer uses only the integer part of
   the 8.8 x, so 0.5 px/frame stutters 1,0,1,0.
6. **`rm -rf generated-code` after any failed build** — a partial generated-code resolves
   sound symbols to zero placeholders and produces baffling errors.
7. `config-linux.properties` needs `builder.parallel=Y`.

## Verify in TOJE

```
mount_disk .../dist/starfield.fd      # NOT the .rom: it polls an SDDRIVE at $E45E and times out
reset
run_frames {n:150}                    # boot menu, PC ~$3393
type_keys {scancodes:["0F"], hold_frames:4}   # 0x0F = boot the floppy, PC -> $019E
run_until_pc {pc:"<MainLoop from main.glb>", max_instructions:40000000}
run_frames {n:100}
screenshot {path:"/tmp/x.png"}        # then Read it
```
- `run_frames` param is **`n`**, not `frames`. `read_memory` needs hex as `"0xNNNN"`
  (`"6587"` parses as decimal).
- **`get_video_mode` is useless** (`$E7DC`/`$E7DD` are write-only → always `00`). Judge the
  mode from screenshot pixel colours.
- The loop draws into the back buffer: a screenshot taken too early shows nothing. Run ≥30
  frames first. This bit me repeatedly — don't chase it as a bug.
- Health check: `gfxlock.bufferSwap.count` must advance ~1 per frame (get its address from
  `generated-code/starfield/FD/main.glb`). Frozen = the current bug.
- Good frame: 576 non-black px = 72 stars, 24 per colour tier (163/231/255).

## Files

- `game-mode/00/main.asm` — the loop to refactor
- `global/global-trailer-includes.asm` — swap WaitVBL for gfxlock
- `global/global-macros.asm` — needs `_music.init.IRQ`
- `objects/music/goldorak/` — asset-only music object (empty `.asm`)
- `objects/title/`, `objects/byfx/` — text objects, each with its own DrawText + font
- Reference: `game-projects/goldorak/game-mode/gamescreen/main.asm`
- Full history: `.superpowers/sdd/progress.md`
