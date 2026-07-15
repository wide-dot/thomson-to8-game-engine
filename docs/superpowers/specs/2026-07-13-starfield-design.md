# Starfield — Multi-plane horizontal parallax (design)

**Date:** 2026-07-13
**Target:** Thomson TO8, video mode BM16 (160×200, 16 colours, 4 bpp) — the mode
the engine boot already sets (`lda #$7B` → `$E7C3`, see `engine/boot/boot-fd.asm`).
**Project:** `game-projects/starfield/` (currently an empty embryo — only `.gitignore`).

## 1. Goal

Replace the empty `starfield` embryo with a polished multi-plane horizontal
starfield: three depth planes of stars scrolling right→left at different speeds,
each plane a distinct brightness (far/slow = dark grey, near/fast = white). The
starfield is built as a **reusable background module** so a future shoot'em-up can
draw game sprites on top of it.

Decisions locked during brainstorming:

| Decision | Value |
|---|---|
| Motion | Horizontal scroll, right→left (R-Type style) |
| Planes | 3, colour = depth: `$444` (slow) / `$AAA` (mid) / `$FFF` (fast) |
| Rendering | **Approach B** — engine double buffer + one erase-list per back page |
| Density | 24 stars/plane → 72 total (`equ`-tunable) |
| Speeds | 1 / 2 / 4 px per frame (8.8 fixed point) |
| Language / comments | English + existing engine French style tolerated |

## 2. Rendering approach (B — double-buffered dirty-pixel)

The engine renders through the gfxlock double buffer (see
`[[to8-engine-main-loop]]`): each frame runs
`update → _gfxlock.on (mount back buffer) → render → _gfxlock.off → _gfxlock.loop`,
and `gfxlock.backBuffer.id` names which of the two pages is currently the back
(draw) buffer. The IRQ (`gfxlock.bufferSwap.check`) performs the actual page swap.

Because there are two physical pages and each is drawn every other frame, each
page must erase *what it itself plotted last time* (two frames ago). We therefore
keep **two erase-lists**, indexed by `gfxlock.backBuffer.id`:

- **`StarfieldUpdate`** (once per frame, 50 Hz): advance every star's `x` by its
  plane speed (8.8 fixed). When a star crosses the left edge, wrap it to the right
  edge (`x = 159.0`) with a fresh random `y` (via `_rnda`, `[[to8-engine-math]]`).
  Positions are shared by both pages.
- **`StarfieldRender`** (once per back-buffer render): for the current
  `backBuffer.id`, (1) erase every pixel recorded in `erase_list[id]` by writing
  colour 0 to its nibble, (2) plot every star at its current position into the
  back buffer, (3) rewrite `erase_list[id]` with the pixels just plotted.

Display sequence over pages A,B,A,B… shows update frames N, N+1, N+2… → smooth
50 Hz apparent motion, while each page correctly cleans its own 2-frame-old pixels.

Rejected alternatives:
- **A (single visible page, direct dirty-pixel)** — cheapest and smoothest but does
  not compose with double-buffered game sprites; rejected because reusability under
  a future game was required.
- **C (full-region clear + redraw)** — trivial logic but clears ~8000 bytes ×2
  banks/frame; wasteful for ~72 sparse pixels.

## 3. Module: `global/starfield.asm`

Self-contained, register-free public interface operating on module-owned RAM:

| Entry | When | Contract |
|---|---|---|
| `StarfieldInit` | once, at mode init | Seed all 72 stars: random `x` (0–159) and `y` (0–199), assign per-plane speed and colour. Clear both erase-lists. |
| `StarfieldUpdate` | mode update routine, 50 Hz | Advance each star `x -= speed` (8.8). On left-edge underflow, wrap to right edge with new random `y`. |
| `StarfieldRender` | mode render routine, inside `_gfxlock.on/off` | Erase `erase_list[backBuffer.id]`, plot all stars into the mounted back buffer, record new pixels into `erase_list[backBuffer.id]`. |

Internal helpers (module-local, not public API):
- `PlotPixel` — set one BM16 pixel to a colour nibble at (x,y). Address =
  `base + y*40 + (x>>1)`; nibble = high if `x` even else low; the exact 4 bpp
  bank/nibble split (which of the two VRAM banks holds which colour bits) is
  pinned from `[[thomson-to8-to9-video]]` at implementation time. Read-modify-write
  so the neighbouring pixel sharing the byte is preserved.
- `ErasePixel` — same address math, writes colour 0 into the pixel's nibble only
  (RMW), never disturbing the paired pixel.

Dependencies: `_rnda` (`[[to8-engine-math]]`), `gfxlock.backBuffer.id`
(`[[to8-engine-main-loop]]`), the BM16 video layout (`[[thomson-to8-to9-video]]`),
palette macros (`[[to8-engine-palette]]`).

## 4. Data layout (module RAM)

```
STARS_PER_LAYER equ 24          ; tunable
NUM_LAYERS      equ 3
NUM_STARS       equ STARS_PER_LAYER*NUM_LAYERS   ; 72

; Per-star parallel arrays (indexed 0..NUM_STARS-1):
star_x_hi  rmb NUM_STARS        ; 8.8 fixed, integer part (pixel x, 0..159)
star_x_lo  rmb NUM_STARS        ; 8.8 fixed, fractional part
star_y     rmb NUM_STARS        ; 0..199

; Per-layer constants (indexed by layer 0..2):
layer_speed  fdb $0100,$0200,$0400   ; 8.8: 1, 2, 4 px/frame
layer_color  fcb col_slow,col_mid,col_fast  ; palette indices for $444/$AAA/$FFF

; Two erase-lists (one per back-buffer id 0/1), each NUM_STARS entries:
;   entry = VRAM byte address (word) + nibble selector (byte)
erase_addr_0 rmb NUM_STARS*2
erase_nib_0  rmb NUM_STARS
erase_addr_1 rmb NUM_STARS*2
erase_nib_1  rmb NUM_STARS
```

Layer of star `i` = `i / STARS_PER_LAYER` (computed once at init; speed/colour can
also be cached per star to avoid the divide in the hot loop — implementation choice).

## 5. Palette

`Pal_starfield`:
- index 0 = black `$000` (background, never plotted — the swap/erase target)
- three grey entries `$444`, `$AAA`, `$FFF` at fixed indices bound to
  `col_slow`/`col_mid`/`col_fast`.

Wired with `_palette.set #Pal_starfield` / `_palette.show`
(`[[to8-engine-palette]]`). Palette asset provided as a small PNG or inline
`fcb`/`fdb` table per the engine's palette-source convention.

## 6. Game mode: `game-mode/00/main.asm` + `main.properties`

Minimal single mode, modeled on
`game-projects/vertical-scroll-tilemap/game-mode/scrollscreen/main.asm` (gfxlock
style, `[[to8-engine-main-loop]]` §5a):

```
        _gameMode.init #GmID_starfield
        _gfxlock.init
        _IRQ.init #UserIRQ,#OUT_OF_SYNC_VBL,#Irq_one_frame
        _palette.set #Pal_starfield
        _palette.show
        jsr   StarfieldInit
        _main.setUpdateRoutine gamemode.update
        _main.setRenderRoutine gamemode.render
        _main.loop.run

gamemode.update
        jsr   StarfieldUpdate
        _main.update.return

gamemode.render
        jsr   StarfieldRender
        _main.render.return

UserIRQ
        jsr   gfxlock.bufferSwap.check
        rts
```

`main.properties` declares the palette asset and the starfield module include,
following the r-type `game-mode/00/main.properties` pattern. `config-linux.properties`
(adapted from `game-projects/r-type/config-linux.properties`) wires the engine
boot/RAMLoader, `builder.lwasm=../../tools/linux/lwasm`, `gameModeBoot=starfield`,
and `builder.diskName=./dist/starfield`.

## 7. Build & run (Linux)

No `build-linux.sh` exists in-repo yet (only macOS/Windows). Add
`game-projects/starfield/build-linux.sh`, adapted from
`game-projects/r-type/build-macos.sh`:
- resolve engine root, reuse the pre-built jar
  `java-generator/target/game-engine-0.0.1-SNAPSHOT-jar-with-dependencies.jar`
- `java -Xverify:none -jar "$JAR" ./config-linux.properties`
- output `./dist/starfield.fd`.

Verified through the **TOJE emulator MCP server** (`~/dev/toje`, wired via this
repo's `.mcp.json` → `toje` server). Relevant tools: `mount_disk`, `reset`,
`run_frames`, `get_video_mode`, `screenshot`, `read_memory`, `read_registers`.

## 8. Testing / verification

Craftsmanship gate — must be confirmed in the TOJE emulator (agentic MCP), not
just assembled. TOJE gives programmatic verification beyond a human eyeball:
1. **Assembles clean** via `build-linux.sh` (lwasm, no errors).
2. **Boots & reaches the mode:** `mount_disk ./dist/starfield.fd` → `reset` →
   `run_frames` N → `get_video_mode` returns BM16 (mode `$7B`); `read_registers`
   confirms the loop is live (PC inside the mode, not a crash/monitor).
3. **Single-layer DEBUG toggle** first: assemble with only the fast plane; step
   frame-by-frame with `run_frames 1` + `screenshot` to confirm erase-list
   correctness — no smearing/leftover pixels on either page. `read_memory` on the
   two VRAM banks can assert only the expected star nibbles are set.
4. **Full 3-plane run:** `run_frames` over many frames + periodic `screenshot`;
   verify three visibly distinct scroll speeds, correct brightness per plane,
   seamless left→right wrap, no flicker/tearing, and no stray pixels accumulating
   over time (proves both erase-lists stay consistent). A pixel-count check on
   VRAM via `read_memory` should stay constant at 72 lit pixels frame to frame.

## 9. Gotchas (locked in)

- Render code must run strictly between `_gfxlock.on` and `_gfxlock.off`
  (`[[to8-engine-main-loop]]` §6) — plotting outside writes to the displayed page.
- `IrqSync` (inside `_IRQ.init`) must run before `IrqOn`.
- Never `INCLUDE` both `gfxlock.asm` and `WaitVBL.asm` — pick gfxlock only.
- BM16 packs 2 pixels/byte: erase and plot are both read-modify-write on a single
  nibble; never write the whole byte or you clobber the neighbour star.
- Erase-list is indexed by `gfxlock.backBuffer.id`, sampled inside render (after
  `_gfxlock.on` has mounted the buffer) — using the wrong id smears the other page.

## 10. Cross-references

- `[[to8-engine-main-loop]]` — gfxlock double buffer, `backBuffer.id`, IRQ, loop order.
- `[[to8-engine-math]]` — `_rnda` PRNG for random y on wrap.
- `[[to8-engine-palette]]` — `_palette.set`/`_palette.show`, palette format.
- `[[thomson-to8-to9-video]]` — BM16 160×200 layout, VRAM banks, nibble/plane split.
- `[[to8-engine-overview]]` — calling convention, macro naming, T2/FD split, boot.
- **TOJE emulator MCP** (`~/dev/toje`, `.mcp.json` → `toje`) — `mount_disk`,
  `run_frames`, `screenshot`, `get_video_mode`, `read_memory` for automated
  visual + VRAM verification.
