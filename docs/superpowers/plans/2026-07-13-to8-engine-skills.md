# to8-engine-* Skill Suite Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Author 14 `to8-engine-*` skills that let an AI write 6809 ASM against the Thomson TO8 game engine.

**Architecture:** One foundation skill (`to8-engine-overview`) that all others cross-link, plus 13 subsystem skills. Each skill is a `SKILL.md` following one shared 8-part template. Content is extracted from `engine/` source headers; worked examples are copied verbatim from `game-projects/`.

**Tech Stack:** Markdown skills (Claude Code skill format), 6809 ASM (lwasm syntax), Thomson TO8.

## Global Constraints

- **Source of truth = `engine/` only.** Examples copied verbatim from `game-projects/`. Hardware detail delegated to `thomson-*` skills via `[[links]]`. **Never** source content from `doc/`, `docs/`, `tutorial/` — they may drift.
- **Language: English.** Prose, headings, comments all English. Keep original ASM identifiers as-is.
- **No invented API.** Every documented routine's calling convention (regs in/out, clobbered, banking) must trace to an actual `engine/` source file read during the task.
- **Every worked example must exist verbatim in the repo** — copied from the named `game-projects/` file, confirmed by grep. No hand-written examples.
- **Skill files live at** `gen-ai/skills/to8-engine-<topic>/SKILL.md` — path relative to the wide-dot workspace root (`../gen-ai/skills/` from this repo), the canonical `thomson-*` home. Create the dir if absent.
- **Frontmatter shape** (mirrors `thomson-*`):
  ```yaml
  ---
  name: to8-engine-<topic>
  description: "Use when <trigger>. <one-line summary>. Keywords: <routine names, macro names, key globals>."
  machines: [to8, to8d]
  user-invocable: false
  sources:
    - engine/<path>.asm
  ---
  ```
- **8-part body template**, every skill, in this order:
  1. Purpose & when to use
  2. Include / dependencies (which files to `INCLUDE`, order, guard symbols)
  3. Calling convention (per public routine/macro: inputs regs+globals, outputs, clobbered regs, banking assumptions)
  4. Globals / memory used (reference `engine/constants.asm`)
  5. Worked example (verbatim ASM from a `game-projects/` file, with its path cited)
  6. Gotchas (T2 vs FD, page switching, gfxlock/VBL timing)
  7. Cross-refs (`[[to8-engine-overview]]`, siblings, `thomson-*`)

- **Per-task validation cycle** (the "test" for a markdown skill):
  1. `head -20 SKILL.md` → frontmatter has all 5 required keys.
  2. Invoke the `skill-review` skill against the file → must pass its checklist.
  3. For each worked example, grep the cited game-project file for a distinctive line of the snippet → must match (proves verbatim, no invention).

---

### Task 0: to8-engine-overview + lock the template

**Files:**
- Create: `../gen-ai/skills/to8-engine-overview/SKILL.md`
- Read (source): `engine/macros.asm`, `engine/constants.asm`, `engine/InitGlobals.asm`, `engine/system/to8/map.const.asm`, `engine/system/to8/macros.asm`, `engine/main/main.asm`, `java-generator/` (build), `scripts/`, a `game-projects/r-type/config-linux.properties`
- Example source: `game-projects/vertical-scroll-tilemap/game-mode/scrollscreen/main.asm` (minimal `_main.loop.run` wiring)

**Interfaces:**
- Produces: the canonical 8-part template + frontmatter every later task copies; the shared vocabulary (calling convention, `_`-prefixed macros, T2/FD conditional assembly, page banking via `_SetCartPageA`) that later skills reference instead of repeating.

- [ ] **Step 1: Read the sources.** Read `engine/macros.asm` (all `_ldd/_ldx/_SetCartPageA/_GetCartPageA/_SetCartPageB` etc.), `engine/constants.asm` (globals region `glb_*`, TO8 register EQUs), `engine/InitGlobals.asm`, `engine/system/to8/*`. Note the T2 (cartridge, `IFDEF T2` → `jsr SetCartPageA`) vs FD (disk, `sta $E7E6`) split.

- [ ] **Step 2: Read the build pipeline.** Read `java-generator/` entry points and `scripts/`; open one `game-projects/r-type/config-*.properties` to document the build inputs (source root, output, T2/FD flag). Cross-ref the `togen`/`to8` shortcuts noted in the project `CLAUDE.md`.

- [ ] **Step 3: Write `SKILL.md`.** Frontmatter per Global Constraints (`name: to8-engine-overview`). Body: (1) purpose = foundation for all `to8-engine-*`; (2) project layout `engine/` + `game-projects/<game>/` and the `INCLUDE "./engine/..."` convention; (3) calling-convention rules (register-passing, no C stack frames), the `_`-macro catalog, T2/FD conditional assembly, page banking; (4) `glb_*` globals map and `constants.asm` register EQUs; (5) worked example = the `_main.setUpdateRoutine`/`_main.loop.run` wiring from the example source, verbatim; (6) gotchas = `glb_ram_end` margin, DP assumptions, T2-vs-FD build flag; (7) cross-ref `[[thomson-6809-lwasm]]`, `[[thomson-to8-to9-memory-map]]`, `[[thomson-to8-to9-mmu]]`.

- [ ] **Step 4: Validate.** Run the per-task validation cycle (frontmatter check, `skill-review`, grep the example line in the cited file).

- [ ] **Step 5: Commit.**
```bash
cd ../gen-ai && git add skills/to8-engine-overview/SKILL.md && git commit -m "feat(skills): add to8-engine-overview"
```

---

### Task 1: to8-engine-memory

**Files:**
- Create: `../gen-ai/skills/to8-engine-memory/SKILL.md`
- Read: `engine/boot/boot-fd.asm`, `engine/boot/boot-t2.asm`, `engine/boot/boot-t2-flash.asm`, `engine/ram/BankSwitch.asm`, `engine/ram/RAMLoaderManagerFd.asm`, `engine/ram/RAMLoaderManagerT2.asm`, `engine/ram/exo/*`, `engine/ram/zx0/*`, `engine/ram/DynCode.asm`, `engine/ram/Clear*.asm`, `engine/ram/CopyPageATo0.asm`, `engine/megarom-t2/t2-flash.asm`, `engine/InitGlobals.asm`
- Example source: `game-projects/road-generator/game-mode/road-debug/main.asm` (uses `_gfxlock` + game-mode load path) and `game-projects/r-type/config-windows.t2.properties` (T2 build)

**Interfaces:**
- Consumes: `[[to8-engine-overview]]` banking vocabulary.
- Produces: the RAMLoader / bank-switch contract that `to8-engine-draw`, `to8-engine-sprites`, `to8-engine-sound` reference for loading compressed assets.

- [ ] **Step 1: Read sources.** Document boot entry differences (fd sector-load vs t2 cartridge vs t2-flash), `BankSwitch` regs, RAMLoader Fd/T2 (input: resource id/page; output: loaded address), Clear routines, DynCode.
- [ ] **Step 2: Write `SKILL.md`** per template. Section 3 must give per-routine reg contracts and which loader to use under T2 vs FD. Section 5 = verbatim boot/load snippet from the example source.
- [ ] **Step 3: Validate** (frontmatter, `skill-review`, grep example).
- [ ] **Step 4: Commit.**
```bash
cd ../gen-ai && git add skills/to8-engine-memory/SKILL.md && git commit -m "feat(skills): add to8-engine-memory"
```

---

### Task 2: to8-engine-main-loop

**Files:**
- Create: `../gen-ai/skills/to8-engine-main-loop/SKILL.md`
- Read: `engine/main/main.asm`, `engine/main/main.macro.asm`, `engine/graphics/buffer/gfxlock.asm`, `engine/graphics/buffer/gfxlock.macro.asm`, `engine/graphics/vbl/WaitVBL.asm`, `engine/irq/Irq.asm`, `engine/irq/IrqSecond.asm`, `engine/irq/IrqObjSmps.asm`, `engine/level-management/LoadGameMode.asm`
- Example source: `game-projects/vertical-scroll-tilemap/game-mode/scrollscreen/main.asm` and `game-projects/road-generator/game-mode/road-debug/main.asm`

**Interfaces:**
- Consumes: `[[to8-engine-overview]]`.
- Produces: the update/render macro contract (`_main.setUpdateRoutine`, `_main.setRenderRoutine`, `_main.loop.run`, `_main.update.return`, `_main.render.return`) and gfxlock double-buffer sequence (`_gfxlock.on/.off/.loop`) that gameplay/graphics skills assume runs each frame.

- [ ] **Step 1: Read sources.** Document the loop: update → gfxlock.on → render → gfxlock.off/loop → VBL. Document IRQ hooks (`IrqSecond` per-second, `IrqObjSmps` sound). Document `LoadGameMode` (input: game-mode id/page).
- [ ] **Step 2: Write `SKILL.md`.** Section 5 = verbatim macro-wiring snippet from example source. Section 6 gotcha: render must sit inside gfxlock; VBL sync via `[[thomson-to8-to9-timer]]`.
- [ ] **Step 3: Validate.**
- [ ] **Step 4: Commit** (`feat(skills): add to8-engine-main-loop`).

---

### Task 3: to8-engine-objects

**Files:**
- Create: `../gen-ai/skills/to8-engine-objects/SKILL.md`
- Read: `engine/object-management/RunObjects.asm`, `Obj_Run.asm`, `Obj_Run.macro.asm`, `RunPgSubRoutine.asm`, `ObjectMove.asm`, `ObjectMoveSync.asm`, `ObjectFall.asm`, `ObjectFallSync.asm`, `objectWave.asm`, `objectWave.macro.asm`, `ObjectWave-subtype.asm`, `MarkObjGone.asm`, `ObjectDp.asm`, `Obj_GetOrientationToPlayer.asm`; object struct in `game-projects/*/global/object.const.asm`
- Example source: `game-projects/day-of-the-tentacle/game-mode/infinite-loop/main.asm` (`LoadObject`/`RunObjects`)

**Interfaces:**
- Consumes: `[[to8-engine-main-loop]]` (RunObjects called from update).
- Produces: object slot/run-list contract — `LoadObject_u`/`LoadObject_x` (returns slot in U/X, Z set on OOM), `UnloadObject_u`/`_x`, `RunObjects`, and the `id`/`object_size`/DP-layout convention consumed by `to8-engine-sprites` and `to8-engine-collision`.

- [ ] **Step 1: Read sources.** Document slot allocation (STACK_SLOT, `InitStack`), run-list link, per-object DP page banking (`_SetCartPageA` before `Obj_Run`), Move/Fall/Wave helpers (reg contracts).
- [ ] **Step 2: Write `SKILL.md`.** Section 3 must state: LoadObject returns Z=0 when no free slot; object code runs with its page banked in. Section 5 = verbatim from example.
- [ ] **Step 3: Validate.**
- [ ] **Step 4: Commit** (`feat(skills): add to8-engine-objects`).

---

### Task 4: to8-engine-collision

**Files:**
- Create: `../gen-ai/skills/to8-engine-collision/SKILL.md`
- Read: `engine/collision/collision.asm`, `collision-do.asm`, `collision-list.asm`, `macros.asm`, `struct_AABB.equ`, `engine/objects/collision/terrainCollision*.asm`
- Example source: `game-projects/r-type/global/weaponcollide.asm` (`_AABB` usage)

**Interfaces:**
- Consumes: `[[to8-engine-objects]]` (object hitbox fields).
- Produces: AABB struct offsets, the `_AABB*` macro contract, and `collision-do`/`collision-list` reg contracts.

- [ ] **Step 1: Read sources.** Document `struct_AABB.equ` field offsets, collision macro inputs (two AABB pointers → carry/flag on overlap), terrainCollision (tilemap-vs-object).
- [ ] **Step 2: Write `SKILL.md`.** Section 5 = verbatim from `weaponcollide.asm`.
- [ ] **Step 3: Validate.**
- [ ] **Step 4: Commit** (`feat(skills): add to8-engine-collision`).

---

### Task 5: to8-engine-input

**Files:**
- Create: `../gen-ai/skills/to8-engine-input/SKILL.md`
- Read: `engine/joypad/InitJoypads.asm`, `ReadJoypads.asm`, `ReadJoypads2.asm`, `ReadJoypadsKbd.asm`, `joypad.md6.asm`, `joypad.buffer.asm`, `joypad.const.asm`, `engine/keyboard/ReadKeyboard.asm`, `engine/keyboard/MapKeyboardToJoypads.asm`
- Example source: `game-projects/road-generator/objects/player-one/player-one.asm` (`ReadJoypads`), `game-projects/sms-player/game-mode/soundtest-ym/main.asm` (`MapKeyboardToJoypads`)

**Interfaces:**
- Consumes: `[[to8-engine-overview]]`.
- Produces: joypad state buffer layout + bit masks (`joypad.const.asm`) and the read routines' reg/output contract consumed by player-object code.

- [ ] **Step 1: Read sources.** Document `InitJoypads`, `ReadJoypads` (output buffer + bit meaning: up/down/left/right/fire), MD6 6-button variant, keyboard→joypad mapping. Delegate hardware bit detail to `[[thomson-to8-to9-pia]]` / `[[thomson-to8-to9-keyboard]]`.
- [ ] **Step 2: Write `SKILL.md`.** Section 4 = joypad buffer + masks table. Section 5 = verbatim from example.
- [ ] **Step 3: Validate.**
- [ ] **Step 4: Commit** (`feat(skills): add to8-engine-input`).

---

### Task 6: to8-engine-sprites

**Files:**
- Create: `../gen-ai/skills/to8-engine-sprites/SKILL.md`
- Read: `engine/graphics/sprite/sprite-background-erase-pack.asm`, `sprite-background-erase-ext-pack.asm`, `sprite-overlay-pack.asm`, `background-erase-mode/*` (BgBufferAlloc, DisplaySprite, DrawSprites, DrawSpritesExtEnc, EraseSprites, CheckSpritesRefresh, DeleteObject, UnsetDisplayPriority), `overlay-mode/*` (BuildSprites, DisplaySprite, DeleteObject)
- Example source: `game-projects/day-of-the-tentacle/object/background2/background2.asm` (`DisplaySprite`), `game-projects/test/game-mode/test/test.asm` (`BuildSprites`)

**Interfaces:**
- Consumes: `[[to8-engine-objects]]` (sprite tied to object), `[[to8-engine-main-loop]]` (draws inside gfxlock).
- Produces: the two rendering-mode contracts (background-erase vs overlay), `DisplaySprite`/`DrawSprites`/`BuildSprites` reg inputs (sprite id, x, y, object slot), and compiled-sprite format pointer.

- [ ] **Step 1: Read sources.** Document when to use background-erase vs overlay, the pack include per mode, DisplaySprite inputs, the erase/refresh lifecycle. Delegate blitting internals to `[[thomson-blitting]]`.
- [ ] **Step 2: Write `SKILL.md`.** Section 3 splits by mode. Section 5 = verbatim from example.
- [ ] **Step 3: Validate.**
- [ ] **Step 4: Commit** (`feat(skills): add to8-engine-sprites`).

---

### Task 7: to8-engine-tilemap

**Files:**
- Create: `../gen-ai/skills/to8-engine-tilemap/SKILL.md`
- Read: `engine/graphics/tilemap/Tilemap.asm`, `Tilemap16bits.asm`, `Tilemaps.asm`, `TilemapBuffer.asm`, `Spritemap.asm`, `TileAnimScript.asm`, `horizontal-scroll/*`, `vscroll/*`, `data-types/*`, `engine/graphics/camera/AutoScroll.asm`, `CheckCameraMove.asm`, `AutoScroll.equ`
- Example source: `game-projects/zeldo/objects/Link/Link.asm` (`AutoScroll`), `game-projects/vertical-scroll-tilemap/game-mode/scrollscreen/main.asm`

**Interfaces:**
- Consumes: `[[to8-engine-main-loop]]`, `[[to8-engine-memory]]` (tile bank loading).
- Produces: tilemap data format, scroll routine contracts (H buffered even/odd/16x16, V stack-push), camera globals (`glb_camera_x_offset`).

- [ ] **Step 1: Read sources.** Document tilemap layout, buffered horizontal scroll variants and when each applies, vertical scroll, camera auto-scroll (input: speed; updates camera globals), TileAnimScript.
- [ ] **Step 2: Write `SKILL.md`.** Section 6 gotcha: `glb_camera_x_offset/4` margin at `$A000` (from `constants.asm`). Section 5 = verbatim from example.
- [ ] **Step 3: Validate.**
- [ ] **Step 4: Commit** (`feat(skills): add to8-engine-tilemap`).

---

### Task 8: to8-engine-animation

**Files:**
- Create: `../gen-ai/skills/to8-engine-animation/SKILL.md`
- Read: `engine/graphics/animation/AnimateSprite.asm`, `AnimateSpriteLoad.asm`, `AnimateSpriteSync.asm`, `AnimateSpriteAdv.asm`, `AnimateSpriteAdvLoad.asm`, `AnimateSpriteAdvSync.asm`, `AnimateMove.asm`, `moveByScript.asm`, `constants-animation.equ`
- Example source: `game-projects/day-of-the-tentacle/object/background1/background1.asm` (`AnimateSprite`)

**Interfaces:**
- Consumes: `[[to8-engine-sprites]]` (drives sprite frame), `[[to8-engine-objects]]` (animation state in object).
- Produces: animation-script data format, `AnimateSprite` vs `AnimateSpriteAdv` differences, Sync/Load variant semantics, `moveByScript` contract.

- [ ] **Step 1: Read sources.** Document animation script bytecode (`constants-animation.equ`), the per-frame state fields, Sync (no reload) vs Load variants, Adv (advanced) extra features.
- [ ] **Step 2: Write `SKILL.md`.** Section 5 = verbatim from example.
- [ ] **Step 3: Validate.**
- [ ] **Step 4: Commit** (`feat(skills): add to8-engine-animation`).

---

### Task 9: to8-engine-draw

**Files:**
- Create: `../gen-ai/skills/to8-engine-draw/SKILL.md`
- Read: `engine/graphics/draw/DrawFullscreenImage.asm`, `DrawFullscreenInterlacedImage.asm`, `DrawHLine.asm`, `engine/graphics/line/hline.asm`, `engine/graphics/image/GetImgIdA.asm`, `engine/graphics/clear/*`, `engine/graphics/codec/bm4.drawChunbks.asm`, `DecRLE00.asm`, `zx0_mega.asm`, `engine/graphics/font/DrawText/DrawText.asm`, `DrawOneChar.asm`, `engine/graphics/font/PrintString/PrintString.asm`
- Example source: `game-projects/sms-player/objects/text/text.asm` (`DrawText`), `game-projects/zeldo/game-mode/LostWoods/MainEngine.asm` (`DecRLE00`)

**Interfaces:**
- Consumes: `[[to8-engine-memory]]` (image data loading), `[[to8-engine-compression]]` (codec decode).
- Produces: fullscreen-image / HLine / text drawing contracts and the in-VRAM codec entry points.

- [ ] **Step 1: Read sources.** Document DrawFullscreenImage (input: image ptr/id, interlaced vs not), HLine (x1,x2,y,color), DrawText/PrintString (string ptr, x, y, font), codec decode-to-screen. Delegate video layout to `[[thomson-to8-to9-video]]`.
- [ ] **Step 2: Write `SKILL.md`.** Section 5 = verbatim from example.
- [ ] **Step 3: Validate.**
- [ ] **Step 4: Commit** (`feat(skills): add to8-engine-draw`).

---

### Task 10: to8-engine-palette

**Files:**
- Create: `../gen-ai/skills/to8-engine-palette/SKILL.md`
- Read: `engine/palette/PalUpdateNow.asm`, `PalUpdateNowLean.asm`, `PalCycling.asm`, `PalRaster_1c.asm`, `engine/palette/color/Pal_black.asm`, `Pal_white.asm`, `engine/objects/palette/fade/fade.asm`, `engine/objects/palette/raster-fade/raster-fade.asm`
- Example source: `game-projects/day-of-the-tentacle/game-mode/infinite-loop/main.asm` (`PalUpdateNow`), `game-projects/sonic-2/game-mode/EHZ/main-engine.asm` (`PalCycling`)

**Interfaces:**
- Consumes: `[[to8-engine-main-loop]]` (palette update timing).
- Produces: palette-buffer format, `PalUpdateNow` (commit buffer → hardware) contract, cycling/raster/fade routine contracts.

- [ ] **Step 1: Read sources.** Document palette buffer, PalUpdateNow vs Lean, PalCycling (rotate range), raster (per-scanline), fade. Delegate color encoding to `[[thomson-to8-to9-palette]]`.
- [ ] **Step 2: Write `SKILL.md`.** Section 6 gotcha: raster needs timer sync (`[[thomson-to8-to9-timer]]`). Section 5 = verbatim from example.
- [ ] **Step 3: Validate.**
- [ ] **Step 4: Commit** (`feat(skills): add to8-engine-palette`).

---

### Task 11: to8-engine-sound

**Files:**
- Create: `../gen-ai/skills/to8-engine-sound/SKILL.md`
- Read: `engine/sound/Smps.asm`, `SmpsMidi.asm`, `SmpsObj.asm`, `Smps_S1.asm`, `Smidi.asm`, `Svgm.asm`, `sn76489.asm`, `PSGlib.asm`, `ym2413.asm`, `YM2413vgm.asm`, `PlayPCM.asm`, `PlayDPCM8kHz.asm`, `PlayDPCM16kHz.asm`, `soundFX.asm`, `soundFX.macro.asm`, `soundFX.data.asm`, `vgc/lib/vgcplayer.asm`, `ChangesFromOriginalSmpsFormat.txt`
- Example source: `game-projects/musique-plus/smps.asm` (`Smps`)

**Interfaces:**
- Consumes: `[[to8-engine-main-loop]]` (`IrqObjSmps` drives playback), `[[to8-engine-memory]]` (music/sample banking).
- Produces: SMPS init/play contract, soundFX macro contract, PCM/DPCM playback contract.

- [ ] **Step 1: Read sources.** Document SMPS driver (init song ptr, per-frame update called from IRQ), PSG vs YM2413 targets, soundFX macro, PCM/DPCM (blocking playback, sample rate). Delegate chip detail to `[[thomson-to8-to9-sound]]` / `[[thomson-to8-to9-pia]]`.
- [ ] **Step 2: Write `SKILL.md`.** Section 5 = verbatim from example. Note the SMPS-format deviations from `ChangesFromOriginalSmpsFormat.txt`.
- [ ] **Step 3: Validate.**
- [ ] **Step 4: Commit** (`feat(skills): add to8-engine-sound`).

---

### Task 12: to8-engine-math

**Files:**
- Create: `../gen-ai/skills/to8-engine-math/SKILL.md`
- Read: `engine/math/Mul9x16.asm`, `CalcSine.asm`, `CalcAngle.asm`, `RandomNumber.asm`, `rnd.macro.asm`, `sinewave.bin` (note: binary table), `engine/math/tmp/atan2.asm`
- Example source: `game-projects/r-type/game-mode/loading/main.asm` (`CalcSine`), `game-projects/r-type/global/objects/loadFirePreset.asm` (`RandomNumber`)

**Interfaces:**
- Consumes: `[[to8-engine-overview]]`.
- Produces: reg contracts for Mul9x16, CalcSine (angle → sine, `sinewave.bin` table), CalcAngle/atan2 (dx,dy → angle), RandomNumber + `_rnd` macro.

- [ ] **Step 1: Read sources.** Document each routine's input reg → output reg, fixed-point format, the sine table dependency. Cross-ref `[[thomson-6809-techniques]]` for MUL/atan2 background.
- [ ] **Step 2: Write `SKILL.md`.** Section 5 = verbatim from example.
- [ ] **Step 3: Validate.**
- [ ] **Step 4: Commit** (`feat(skills): add to8-engine-math`).

---

### Task 13: to8-engine-compression

**Files:**
- Create: `../gen-ai/skills/to8-engine-compression/SKILL.md`
- Read: `engine/compression/exomizer/exomizer.asm`, `engine/compression/zx0/zx0_6809_standard.asm`, `zx0_6809_mega.asm`, `zx0_6809_mega_back.asm`, `zx0_6809_turbo.asm`, `engine/compression/mx0/*`, `engine/graphics/codec/DecRLE00.asm`
- Example source: `game-projects/zeldo/game-mode/LostWoods/MainEngine.asm` (`DecRLE00`); if a zx0/exo caller exists, grep `game-projects` for `zx0`/`exomizer` and cite it instead

**Interfaces:**
- Consumes: `[[to8-engine-overview]]`.
- Produces: runtime decompressor contracts (src ptr, dst ptr → decompressed) that `[[to8-engine-memory]]` (RAMLoader exo/zx0) and `[[to8-engine-draw]]` (codec) build on.

- [ ] **Step 1: Read sources.** Document each decompressor's reg contract, zx0 standard vs mega (banked) vs turbo (speed) trade-off, RLE00. Cross-ref host-side packing tools in `[[thomson-cross-dev]]`.
- [ ] **Step 2: Write `SKILL.md`.** Section 5 = verbatim from a real caller (grep first to confirm).
- [ ] **Step 3: Validate.**
- [ ] **Step 4: Commit** (`feat(skills): add to8-engine-compression`).

---

### Task 14: Suite integration + symlinks

**Files:**
- Modify: project `.claude/skills/` (add symlinks)
- Read: all 14 created `SKILL.md`

**Interfaces:**
- Consumes: all prior tasks.
- Produces: a coherent, discoverable, cross-linked suite usable in this repo.

- [ ] **Step 1: Cross-link audit.** For each skill, confirm its `[[...]]` links resolve to a real sibling `to8-engine-*` or existing `thomson-*` skill. Fix broken links inline.
- [ ] **Step 2: Symlink into project.** For each `to8-engine-*`, create a symlink under the project `.claude/skills/` (matching how `thomson-*` are exposed). Verify with `ls -l .claude/skills | grep to8-engine`.
- [ ] **Step 3: Coverage check.** Confirm every `engine/` top-level dir maps to at least one skill (per the design table). List any orphan dir; if a real public API was missed, add it to the relevant skill.
- [ ] **Step 4: Final validation.** Run `skill-review` across all 14; all pass.
- [ ] **Step 5: Commit** (`chore(skills): wire to8-engine-* suite into project`).

---

## Self-Review

- **Spec coverage:** All 14 skills from the spec table have a task (Tasks 0–13); Task 14 covers placement/symlinks + coverage check. Shared template, frontmatter, source-of-truth constraint, and validation-via-`skill-review` are in Global Constraints and every task's validation step. ✅
- **Placeholders:** No "TBD/TODO". Every task names exact engine source files, exact example game-project file (all confirmed to exist via grep during planning), and exact validation commands. The worked-example *text* is intentionally not inlined because it must be copied verbatim from the cited file at authoring time — the grep-verify step enforces this. ✅
- **Type/name consistency:** Routine names (`LoadObject_u/_x`, `RunObjects`, `DisplaySprite`, `BuildSprites`, `AutoScroll`, `PalUpdateNow`, `_main.loop.run`, `_gfxlock.*`, `CalcSine`, `DecRLE00`) match the engine symbols verified during planning and are used consistently across the Interfaces blocks. ✅
