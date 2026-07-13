# Design: `to8-engine-*` Skill Suite

Date: 2026-07-13
Status: Approved (design), pending implementation plan

## Goal

Author a suite of skills, prefixed `to8-engine-*`, that give an AI everything it
needs to **write 6809 assembly code against the Thomson TO8 game engine (the
framework)**. The `thomson-*` skills already cover the *hardware/platform*; this
suite covers *this engine's API, calling conventions, and integration
contracts*.

## Hard Constraint — Source of Truth

- Content is derived **only from the `engine/` directory**, with worked examples
  pulled from `game-projects/`, and cross-links to the existing `thomson-*`
  skills for hardware detail.
- **Ignore `doc/`, `docs/`, `tutorial/`** as content sources — they may drift
  from the code. Read engine source headers for the real register contract; do
  not invent API surface.

## Decisions

- **Granularity:** Hybrid — one foundation skill (`to8-engine-overview`) that all
  others reference, plus focused skills that map to engine subsystems, with
  trivially small subsystems merged (e.g. `joypad` + `keyboard` = `input`).
- **Language:** English (engine comments and identifiers are English).
- **Depth:** API contract + ready-to-copy ASM code examples taken from
  `game-projects/`.

## Skill Set — 14 skills

### Foundation

| Skill | Covers (`engine/` dirs) |
|-------|-------------------------|
| `to8-engine-overview` | Foundation all others reference: calling convention (regs in/out), `macros.asm`, `constants.asm`, naming rules, T2 (cartridge) vs FD (disk) conditional assembly, project layout, build pipeline (java-generator / `togen` + `lwasm`). |
| `to8-engine-memory` | `boot/` (fd, t2, t2-flash), `ram/` (banking, RAMLoader Fd/T2, DynCode, clear routines), `megarom-t2/`, `InitGlobals.asm`. |
| `to8-engine-main-loop` | `main/` update/render macros, gfxlock double-buffer (`graphics/buffer/`), `graphics/vbl/`, `irq/`, `level-management/` game modes. |

### Gameplay

| Skill | Covers |
|-------|--------|
| `to8-engine-objects` | `object-management/`, `objects/` (non-graphics): slots, run-list, Load/Unload, ObjectMove/Fall/Wave, `Obj_Run`, subroutine dispatch. |
| `to8-engine-collision` | `collision/`, `objects/collision/`: AABB struct, collision-do/list, terrainCollision. |
| `to8-engine-input` | `joypad/` (ReadJoypads, md6, buffer) + `keyboard/` (MapKeyboardToJoypads, ReadKeyboard). |

### Graphics

| Skill | Covers |
|-------|--------|
| `to8-engine-sprites` | `graphics/sprite/`: background-erase vs overlay modes, DisplaySprite/DrawSprites, compiled sprites, packs. |
| `to8-engine-tilemap` | `graphics/tilemap/` (H/V scroll, Spritemap, TileAnimScript), `graphics/camera/` (AutoScroll, CheckCameraMove). |
| `to8-engine-animation` | `graphics/animation/`: AnimateSprite / AnimateSpriteAdv (+Sync/Load variants), moveByScript, AnimateMove. |
| `to8-engine-draw` | `graphics/draw/` (fullscreen image, HLine), `line/`, `image/`, `clear/`, `codec/` (bm4, RLE), `font/` (DrawText, PrintString). |
| `to8-engine-palette` | `palette/` (PalUpdateNow, PalCycling, PalRaster), `objects/palette/` (fade, raster-fade), color helpers. |

### Audio / Math / System

| Skill | Covers |
|-------|--------|
| `to8-engine-sound` | `sound/`: SMPS family, PSG `sn76489`, `ym2413`, DPCM/PCM playback, VGC/VGM, soundFX, Smidi. |
| `to8-engine-math` | `math/`: Mul9x16, CalcSine, CalcAngle/atan2, RandomNumber (+ rnd macro). |
| `to8-engine-compression` | `compression/`: exomizer, zx0 (standard/mega/turbo), runtime decompression contract (used by memory loaders and graphics codecs). |

## Shared Skill Template

Every skill has the same shape:

1. **Frontmatter** (mirrors `thomson-*`):
   - `name: to8-engine-<topic>`
   - `description:` starts with "Use when …" then a keyword list (routine names,
     macro names, key globals) for retrieval matching.
   - `machines: [to8, to8d]`
   - `user-invocable: false`
   - `sources:` list of the `engine/` file paths the skill documents.
2. **Purpose & when to use.**
3. **Include / dependencies** — which `.asm` / `.equ` / `.macro.asm` files to
   `INCLUDE` and in what order; guard symbols.
4. **Calling convention** — per public routine/macro: inputs (registers +
   globals), outputs, clobbered registers, banking assumptions (which RAM/cart
   page must be selected).
5. **Globals / memory** consumed, referencing `constants.asm`.
6. **Worked example** — a real ASM snippet lifted from a `game-projects/` game.
7. **Gotchas** — T2 vs FD differences, page switching, gfxlock timing, VBL sync.
8. **Cross-refs** — `[[to8-engine-overview]]`, sibling `to8-engine-*`, and
   relevant `thomson-*` hardware skills.

## Placement

- Skill files live at `gen-ai/skills/to8-engine-<topic>/SKILL.md`, beside the
  existing `thomson-*` skills (canonical home), and are symlinked into the
  project `.claude/skills/` for use in this repo.
- Build/tooling knowledge lives inside `to8-engine-overview` (no separate
  `to8-engine-build` skill).

## Phasing (build order)

- **Phase 0** — `to8-engine-overview`; lock the shared template.
- **Phase 1** — `to8-engine-memory`, `to8-engine-main-loop`.
- **Phase 2** — `to8-engine-objects`, `to8-engine-collision`, `to8-engine-input`.
- **Phase 3** — `to8-engine-sprites`, `to8-engine-tilemap`,
  `to8-engine-animation`, `to8-engine-draw`, `to8-engine-palette`.
- **Phase 4** — `to8-engine-sound`, `to8-engine-math`, `to8-engine-compression`.

Each skill: read the engine source headers for the true contract, extract one
worked example from a game-project, cross-link, then validate with the
`skill-review` skill (Thomson-specific criteria).

## Success Criteria

- An AI given only these skills (plus `thomson-*`) can write a new object,
  render a sprite, scroll a tilemap, play a sound, and boot a game on TO8 —
  producing code that assembles under `lwasm` with the correct register/banking
  contract, without reading the engine source first.
- Every documented routine's calling convention traces to an actual
  `engine/` source file.
