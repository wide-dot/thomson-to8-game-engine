# Multi-plane Starfield Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a polished 3-plane horizontal parallax starfield as a reusable TO8 background module in `game-projects/starfield/`.

**Architecture:** One standalone game mode boots straight into the starfield. A self-contained module `global/starfield.asm` owns all star RAM (array-of-structs) and exposes `StarfieldInit` / `StarfieldUpdate` / `StarfieldRender`. Rendering uses WaitVBL double buffering with one erase-list per physical back page (dirty-pixel approach B), so game sprites can later be layered on top. Verification is done through the TOJE emulator MCP server (build the `.fd`, then mount_disk / boot the floppy / run_frames / screenshot).

**Tech Stack:** 6809 assembly (LWASM), the wide-dot TO8 game engine, the Java BuildDisk generator, TOJE emulator MCP.

## Global Constraints

- Video mode: BM16 160×200×16 colours (`$E7DC=$7B`), set by engine boot — do not change it.
- BM16 VRAM layout: 2 pixels per byte, high nibble = left pixel, low nibble = right pixel; each byte holds a full 0–15 colour index. Two 8000-byte planes in **data space**. **The planes are INVERTED: RAM B is mapped at `$A000`, RAM A at `$C000`.** The asset encoder (`PngToBottomUpB16Bin`) builds RAM A as its *first* 8000 bytes — pixel columns 0,1 of each 4-pixel group — and RAM B as the second 8000 (columns 2,3). So columns 0,1 live at **`$C000`** and columns 2,3 at **`$A000`**. For pixel `(x,y)`, `x∈0..159`, `y∈0..199`:
  - plane base = **`$C000` if `(x AND 2)=0`, else `$A000`**
  - byte offset = `y*40 + (x>>2)`
  - nibble = high (`<<4`) if `x` even, low if `x` odd
  - Getting the planes backwards renders every pixel ±2 px off depending on the parity of `x>>1`; a scrolling star then jitters back and forth (appears to move backwards) instead of drifting smoothly. **Verify plane order POSITIONALLY** — check left-to-right pixel order, not just that N distinct colours appear (a `Counter.most_common()` dump is ordered by count, not position, and will hide this).
- Palette pipeline (from `PaletteTO8.getPaletteData`): the generator reads PNG palette **indices 1..16** → engine colours **0..15** (`PNG index k → engine colour k-1`). Greys pass through the EF9369 DAC ladder `to8RGB = {0,97,122,143,158,171,184,194,204,212,219,227,235,242,250,255}`; engine nibble levels 4/10/15 = PNG RGB **158 / 219 / 255**.
- Star colours (engine colour index = the nibble written to VRAM): black=0 (background, never plotted), slow=1 ($444), mid=2 ($AAA), fast=3 ($FFF).
- Density: `STARS_PER_LAYER equ 24`, `NUM_LAYERS equ 3`, `NUM_STARS equ 72`. Speeds (8.8 fixed, 16-bit subtract/frame): slow `$0100`, mid `$0200`, fast `$0300` = 1 / 2 / 3 px per frame. **Speeds must be whole pixels** ($0100 units): the renderer uses only the integer part of x, so a fractional speed quantises (0.5 px/frame renders steps of 1,0,1,0 = visible stutter). On a 160px grid at 50Hz, 1 px/frame is the floor for perfectly uniform motion.
- Render must run **after `jsr WaitVBL`** (which flips the buffers and mounts the new back buffer at `$A000`/`$C000`), so the frame is drawn into the page that is not being displayed. See the WaitVBL constraint below. Never INCLUDE both `gfxlock.asm` and `WaitVBL.asm`.
- Erase/plot are read-modify-write on a single nibble only (2 pixels share a byte).
- Build on Linux: `bash build-linux.sh` wraps `java -Xverify:none -jar java-generator/target/game-engine-0.0.1-SNAPSHOT-jar-with-dependencies.jar ./config-linux.properties` (jar already built). lwasm at `tools/linux/lwasm`. `config-linux.properties` must include `builder.parallel=Y` (required by the current jar).
- **NEVER use `RMB` for data in this game mode.** The mode is assembled to a RAW binary loaded
  contiguously at `$6100`. `RMB` advances the assembler's location counter but emits **no bytes**, so
  every byte after it lands one address early at runtime and later routines are entered one byte in
  (first opcode skipped) — a silent, catastrophic corruption. Reserve loaded data with **`fcb` / `fdb` /
  `fill 0,n`**, exactly as the engine itself does. (This cost Task 2 a long debug: it broke
  `jsr IrqInit` → TIMERPT never set → no IRQ.)
- **Frame sync is `WaitVBL`, not gfxlock.** `vertical-scroll-tilemap` (the gfxlock sample) is stale and
  no longer builds; **r-type is the working reference** and uses `engine/graphics/vbl/WaitVBL.asm` —
  a synchronous page flip needing **no IRQ**. `WaitVBL` sets `$E7DD` (display page), `$E7E5` (data page,
  always the opposite → the back buffer at `$A000`/`$C000`), and maintains `gfxlock.backBuffer.id` (0/1),
  so the spec's approach-B per-page erase-lists work unchanged. Never INCLUDE `gfxlock.asm` alongside it.
  The mode's shape (established in Tasks 1–2, do not change):
  ```asm
        ldd   #Pal_black                ; black palette FIRST: the disk loader leaves
        std   Pal_current               ; raw data in the video pages
        clr   PalRefresh
        jsr   PalUpdateNow
        lda   #$C0                      ; onscreen video page = 3, border 0
        sta   $E7DD
        _gameMode.init #GmID_starfield  ; InitGlobals + InitStack + LoadAct (clears pages 2/3)
        _palette.set #Pal_starfield
        _palette.show
        jsr   StarfieldInit             ; (Task 3)
  MainLoop
        jsr   WaitVBL                   ; wait VBL + flip buffers
        jsr   StarfieldUpdate           ; (Task 4)
        jsr   StarfieldRender           ; (Task 3) draws into the back buffer
        bra   MainLoop
  ```
- **TOJE boot recipe (verified — boot the FD, not the cartridge):**
  1. `mcp__toje__mount_disk { "path": ".../game-projects/starfield/dist/starfield.fd" }`
  2. `mcp__toje__reset`
  3. `mcp__toje__run_frames { "n": 150 }` — reach the TO8 boot menu (PC parks at `$3393`/`$3395`).
  4. `mcp__toje__type_keys { "scancodes": ["0F"], "hold_frames": 4 }` — `0x0F` (SCANCODE_B) boots the floppy; PC → `$019E`.
  5. `mcp__toje__run_until_pc { "pc": "0x612B", "max_instructions": 40000000 }` — MainLoop; `reached:true` = init survived. (Re-check `MainLoop`'s address in `generated-code/starfield/FD/main.glb` after each build.)
  6. `mcp__toje__run_frames { "n": 100 }` then `mcp__toje__screenshot { "path": "/tmp/x.png" }` and Read the PNG.
  - Do **not** use the `.rom`/cartridge path: it polls a bit-banged SPI/SDDRIVE at `$E45E` and times out to the monitor.
  - `run_frames` takes param **`n`** (NOT `frames`). `read_memory` needs hex as **`"0xNNNN"`** (`"6587"` parses as decimal!).
  - **Do NOT use `get_video_mode`** — `$E7DC`/`$E7DD` are write-only, it always returns `mode:"00"`, `display_page:0`. Confirm BM16 via screenshot pixel colours.
  - **Screenshot the front buffer only after the loop has run ≥30 frames** — the loop draws into the back buffer, so a screenshot taken too early (or right after a `write_memory` into `$A000`) shows nothing. This is not a bug.
  - An illegal opcode makes TOJE freeze PC in place and spin (`run_frames` never returns) — if PC stops advancing, suspect a crash into data/VRAM.
- 6809 reminder: an indexed offset register must differ from the loaded register (`lda a,x` OK, `ldb b,x` ILLEGAL). `NUM_STARS=72`; struct walks use a single pointer + `leau`, so no large computed offsets are needed.
- Spec: `docs/superpowers/specs/2026-07-13-starfield-design.md`.

---

## File Structure

All paths under `game-projects/starfield/`:

- `config-linux.properties` — BuildDisk config (engine boot/loader wiring, gameMode, disk name).
- `build-linux.sh` — Linux build wrapper (adapted from `game-projects/r-type/build-macos.sh`).
- `game-mode/00/main.properties` — mode asset/palette/act declarations.
- `game-mode/00/main.asm` — mode entry: init, palette/page setup, WaitVBL MainLoop.
- `game-mode/00/ram-data.asm` — object RAM boilerplate (engine expects it).
- `game-mode/00/image/palette.png` — 17+ entry indexed PNG defining the 4 star colours.
- `global/global-preambule-includes.asm` — engine equates/macros/constants + project globals.
- `global/global-trailer-includes.asm` — engine routine bodies (InitGlobals, Irq, PalUpdateNow, RandomNumber, …).
- `global/global-macros.asm` — `_gameMode.init`, `_IRQ.init`, `_palette.set`, `_palette.show`.
- `global/global-equates.asm` — project equates (`OUT_OF_SYNC_VBL`).
- `global/global-variables.asm` — `GLOBAL_VARIABLES` base address.
- `global/starfield.asm` — the starfield module (data + Init/Update/Render + PlotPixel/ErasePixel).
- `tools/gen-palette.py` — helper that generates `palette.png` deterministically.

`.gitignore` already exists (ignores `dist/`, `generated-code/`).

---

## Task 1: Bootable black-screen mode (scaffold)

Stand up the whole project so it builds a `.fd` and boots into an empty BM16 mode with the star palette loaded (black screen). No stars yet. This locks the build/boot/verify loop.

**Files:**
- Create: `game-projects/starfield/config-linux.properties`
- Create: `game-projects/starfield/build-linux.sh`
- Create: `game-projects/starfield/game-mode/00/main.properties`
- Create: `game-projects/starfield/game-mode/00/main.asm`
- Create: `game-projects/starfield/game-mode/00/ram-data.asm`
- Create: `game-projects/starfield/game-mode/00/image/palette.png` (via `tools/gen-palette.py`)
- Create: `game-projects/starfield/tools/gen-palette.py`
- Create: `game-projects/starfield/global/global-preambule-includes.asm`
- Create: `game-projects/starfield/global/global-trailer-includes.asm`
- Create: `game-projects/starfield/global/global-macros.asm`
- Create: `game-projects/starfield/global/global-equates.asm`
- Create: `game-projects/starfield/global/global-variables.asm`

**Interfaces:**
- Consumes: engine `_gameMode.init`, `_gfxlock.*`, `_IRQ.init`, `_palette.set`/`_palette.show`, `PalUpdateNow`, `IrqInit`/`IrqSync`/`IrqOn`, generated `GmID_starfield`, generated `Pal_starfield`.
- Produces: a bootable `dist/starfield.fd`; the `gamemode.update`/`gamemode.render` hook points and `UserIRQ` that later tasks fill in.

- [ ] **Step 1: Write the palette PNG helper**

Create `tools/gen-palette.py`:

```python
#!/usr/bin/env python3
"""Generate game-mode/00/image/palette.png for the starfield.

PaletteTO8.getPaletteData reads PNG palette indices 1..16 -> engine colours 0..15.
Engine nibble levels 4/10/15 correspond to EF9369 DAC RGB 158/219/255.
Layout: idx0 black, idx1 black(col0), idx2 grey158(col1 slow $444),
idx3 grey219(col2 mid $AAA), idx4 white255(col3 fast $FFF), rest black.
"""
from PIL import Image
import os

pal = [0, 0, 0] * 256
def setc(i, r, g, b):
    pal[i*3:i*3+3] = [r, g, b]

setc(0, 0, 0, 0)        # ignored by palette gen, keep black
setc(1, 0, 0, 0)        # engine colour 0 = black (background)
setc(2, 158, 158, 158)  # engine colour 1 = slow  ($444)
setc(3, 219, 219, 219)  # engine colour 2 = mid   ($AAA)
setc(4, 255, 255, 255)  # engine colour 3 = fast  ($FFF)

img = Image.new("P", (16, 1), 0)
img.putpalette(pal)
img.putdata(bytes(range(16)))
out = os.path.join(os.path.dirname(__file__), "..", "game-mode", "00", "image", "palette.png")
os.makedirs(os.path.dirname(out), exist_ok=True)
img.save(out)
print("wrote", os.path.normpath(out))
```

- [ ] **Step 2: Run the helper to produce the PNG**

Run:
```bash
cd game-projects/starfield && python3 tools/gen-palette.py
```
Expected: `wrote .../game-mode/00/image/palette.png`. Verify indexed palette:
```bash
python3 -c "from PIL import Image; im=Image.open('game-mode/00/image/palette.png'); p=im.getpalette(); print(im.mode, im.size, p[3:15])"
```
Expected: `P (16, 1) [0, 0, 0, 158, 158, 158, 219, 219, 219, 255, 255, 255]`

- [ ] **Step 3: Write the project global boilerplate**

Create `global/global-variables.asm`:
```asm
 IFNDEF GLOBAL_VARIABLES
GLOBAL_VARIABLES EQU $9DF0
 ENDC
```

Create `global/global-equates.asm`:
```asm
 IFNDEF GLOBAL_EQUATES
GLOBAL_EQUATES EQU 1
OUT_OF_SYNC_VBL EQU 255
NO_CALLBACK     EQU $0000
 ENDC
```

Create `global/global-macros.asm`:
```asm
_IRQ.init MACRO
    jsr   IrqInit
    ldd   \1
    std   Irq_user_routine
    lda   \2
    ldx   \3
    jsr   IrqSync
    jsr   IrqOn
    ENDM

_gameMode.init MACRO
    jsr   InitGlobals
    jsr   InitStack
    jsr   LoadAct
    lda   \1
    sta   glb_Cur_Game_Mode
    ENDM

_palette.set MACRO
    ldd   \1
    std   Pal_current
    ENDM

_palette.show MACRO
    clr   PalRefresh
    jsr   PalUpdateNow
    ENDM
```

Create `global/global-preambule-includes.asm`:
```asm
DO_NOT_WAIT_VBL equ 1
SOUND_CARD_PROTOTYPE equ 1

    INCLUDE "./engine/system/to8/memory-map.equ"
    INCLUDE "./engine/constants.asm"
    INCLUDE "./engine/macros.asm"
    INCLUDE "./engine/system/to8/map.const.asm"
    INCLUDE "./engine/math/rnd.macro.asm"

    INCLUDE "./global/global-equates.asm"
    INCLUDE "./global/global-macros.asm"
    INCLUDE "./global/global-variables.asm"
```

Create `global/global-trailer-includes.asm`:
```asm
    INCLUDE "./engine/InitGlobals.asm"
    INCLUDE "./engine/ram/BankSwitch.asm"
    INCLUDE "./engine/palette/PalUpdateNow.asm"
    INCLUDE "./engine/ram/ClearDataMemory.asm"
    INCLUDE "./engine/object-management/RunObjects.asm"
    INCLUDE "./engine/level-management/LoadGameMode.asm"
    INCLUDE "./engine/math/RandomNumber.asm"
    INCLUDE "./engine/irq/Irq.asm"
```

- [ ] **Step 4: Write `game-mode/00/ram-data.asm`**

```asm
; ext_variables_size is for dynamic objects
ext_variables_size           equ 20
nb_dynamic_objects           equ 8
nb_graphical_objects         equ 8

MainCharacter                equ dp

Dynamic_Object_RAM           fill 0,(nb_dynamic_objects)*object_size
Dynamic_Object_RAM_End
```

- [ ] **Step 5: Write `game-mode/00/main.asm` (skeleton, no stars)**

```asm
DEBUG EQU 1

        INCLUDE "./global/global-preambule-includes.asm"
        INCLUDE "./engine/graphics/buffer/gfxlock.macro.asm"
        INCLUDE "./engine/main/main.macro.asm"

        org   $6100
        opt   cd,cc

* ============================================================================
* Init
* ============================================================================
        _gameMode.init #GmID_starfield
        _gfxlock.init
        _IRQ.init #UserIRQ,#OUT_OF_SYNC_VBL,#Irq_one_frame
        _palette.set #Pal_starfield
        _palette.show

        _main.setUpdateRoutine gamemode.update
        _main.setRenderRoutine gamemode.render
        _main.loop.run

gamemode.update
        _main.update.return

gamemode.render
        _main.render.return

UserIRQ
        jsr   gfxlock.bufferSwap.check
        rts

* ---------------------------------------------------------------------------
* Game Mode RAM variables
* ---------------------------------------------------------------------------
        INCLUDE "./game-mode/00/ram-data.asm"

* ============================================================================
* Routines
* ============================================================================
        INCLUDE "./engine/main/main.asm"
        INCLUDE "./engine/graphics/buffer/gfxlock.asm"
        INCLUDE "./global/global-trailer-includes.asm"
```

- [ ] **Step 6: Write `game-mode/00/main.properties`**

```properties
engine.asm.mainEngine=./game-mode/00/main.asm

# Palette + act
palette.Pal_starfield=./game-mode/00/image/palette.png
actBoot=default
act.default.palette=Pal_starfield
act.default.screenBorder=0
act.default.backgroundSolid=0
```

- [ ] **Step 7: Write `config-linux.properties`**

```properties
# Engine loader
engine.asm.boot.fd=../../engine/boot/boot-fd.asm
engine.asm.RAMLoaderManager.fd=../../engine/ram/RAMLoaderManagerFd.asm
engine.asm.RAMLoader.fd=../../engine/ram/zx0/RAMLoaderFd.asm
engine.asm.boot.t2=../../engine/boot/boot-t2.asm
engine.asm.RAMLoaderManager.t2=../../engine/ram/RAMLoaderManagerT2.asm
engine.asm.RAMLoader.t2=../../engine/ram/zx0/RAMLoaderT2.asm
engine.asm.boot.t2flash=../../engine/boot/boot-t2-flash.asm
engine.asm.t2flash=../../engine/megarom-t2/t2-flash.asm

# Game definition
gameModeBoot=starfield
gameMode.starfield=./game-mode/00/main.properties

# Build parameters
builder.lwasm=../../tools/linux/lwasm
builder.lwasm.pragma=undefextern
builder.lwasm.includeDirs=.,../..,../
builder.lwasm.define=boot_color_gr=$00,boot_color_b=$00
builder.debug=Y
builder.logToConsole=Y
builder.diskName=./dist/starfield
builder.t2Name=STARFIELD
builder.generatedCode=./generated-code
builder.constAnim=./engine/graphics/animation/constants-animation.equ
builder.to8.memoryExtension=Y
builder.compilatedSprite.useCache=Y
builder.compilatedSprite.maxTries=500000
```

- [ ] **Step 8: Write `build-linux.sh`**

```bash
#!/usr/bin/env bash
# Build the starfield .fd on Linux using the pre-built BuildDisk jar.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENGINE_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
JAR="$ENGINE_ROOT/java-generator/target/game-engine-0.0.1-SNAPSHOT-jar-with-dependencies.jar"
CONFIG="./config-linux.properties"

command -v java >/dev/null || { echo "Error: java not found" >&2; exit 1; }
if [ ! -f "$JAR" ]; then
    echo "==> Building generator jar..."
    (cd "$ENGINE_ROOT/java-generator" && mvn -q clean compile assembly:single)
fi
cd "$SCRIPT_DIR"
echo "==> Generating starfield from $CONFIG ..."
java -Xverify:none -jar "$JAR" "$CONFIG"
echo "==> Outputs:"; ls -la dist/ 2>/dev/null || echo "  (no dist/)"
```
Then: `chmod +x game-projects/starfield/build-linux.sh`.

- [ ] **Step 9: Build**

Run:
```bash
cd game-projects/starfield && bash build-linux.sh
```
Expected: build completes, `dist/starfield.fd` exists. If lwasm reports an undefined symbol (e.g. `InitStack`, `LoadAct`, `object_size`), compare against `game-projects/vertical-scroll-tilemap` (same include set, known-good) and reconcile before proceeding.

- [ ] **Step 10: Verify boot in TOJE**

Use the `toje` MCP tools (substitute the absolute path to the built `.fd`):
```
[boot via the TOJE recipe in Global Constraints: load_cartridge starfield.rom -> run_frames n=120 -> type_keys ["1F"]]
mcp__toje__run_frames { "n": 300 }
mcp__toje__get_video_mode
```
Expected `get_video_mode`: `mode`=`"7B"` (BM16), `border_color`=`0`.
```
mcp__toje__screenshot { "path": "/tmp/sf-task1.png" }
mcp__toje__read_registers
```
Read `/tmp/sf-task1.png` — expected: solid black screen, no crash/monitor text. `read_registers`: PC in RAM engine range (`$6xxx`), not a monitor address.

- [ ] **Step 11: Commit**

```bash
cd /home/robin/github/wide-dot/thomson-to8-game-engine
git add game-projects/starfield
git commit -m "feat(starfield): bootable BM16 mode with star palette (black screen)"
```

---

## Task 2: PlotPixel / ErasePixel BM16 primitive

Create `global/starfield.asm` with the address helper and pixel primitive, and prove the BM16 nibble/bank math empirically by plotting known pixels and screenshotting.

**Files:**
- Create: `game-projects/starfield/global/starfield.asm`
- Modify: `game-projects/starfield/game-mode/00/main.asm` (INCLUDE the module; temporary plot-test in render)
- Modify: `game-projects/starfield/config-linux.properties` (temporary `PLOT_TEST` define)

**Interfaces:**
- Produces:
  - `SF_PixelAddr` — In: `A`=y (0..199), `B`=x (0..159). Out: `X`=VRAM byte address in the mounted back buffer, carry set ⇒ low nibble (x odd), carry clear ⇒ high nibble (x even). Clobbers A,B,D,X. Preserves U,Y.
  - `PlotPixel` — In: `A`=y, `B`=x, `sf_color` (module byte)=colour 0..15. Sets that pixel (RMW single nibble). Clobbers A,B,D,X. Preserves U,Y.
  - `ErasePixel` — In: `A`=y, `B`=x. Clears that pixel's nibble to 0 (RMW). Clobbers A,B,D,X. Preserves U,Y.
  - `sf_color` — module scratch byte holding the colour for `PlotPixel`.

- [ ] **Step 1: Create `global/starfield.asm` with the primitive**

```asm
* ============================================================================
* starfield.asm — multi-plane horizontal parallax starfield (BM16 160x200)
* ----------------------------------------------------------------------------
* BM16 VRAM (data space): 2 px/byte, high nibble=left px, low nibble=right px.
* PLANES INVERTED: RAM B @ $A000, RAM A @ $C000 -> columns 0,1 (x&2==0) live
* at $C000 and columns 2,3 (x&2==2) at $A000.
* byte offset = y*40 + (x>>2). nibble high if x even, low if x odd.
* ============================================================================

SF_BANK01   equ  $C000      ; RAM A — pixel columns 0,1  ((x AND 2) = 0)
SF_BANK23   equ  $A000      ; RAM B — pixel columns 2,3  ((x AND 2) = 2)

sf_color    fcb  0              ; colour PlotPixel writes (0..15)  [fcb, never rmb]

* ---------------------------------------------------------------------------
* SF_PixelAddr — In: A=y, B=x. Out: X=byte addr, carry=1 if low nibble.
* Clobbers A,B,D,X. Preserves U,Y.
* ---------------------------------------------------------------------------
SF_PixelAddr
        pshs  b                 ; [S] = x
        ldb   #40
        mul                     ; D = y*40  (y<=199 -> <=7960)
        tfr   d,x               ; X = y*40
        ldb   ,s
        andb  #2                ; x & 2 -> which plane holds this pixel
        beq   @bank01
        leax  SF_BANK23,x      ; columns 2,3 -> RAM B @ $A000
        bra   @off
@bank01
        leax  SF_BANK01,x      ; columns 0,1 -> RAM A @ $C000
@off
        ldb   ,s                ; B = x
        lsrb
        lsrb                    ; B = x>>2 (byte column)
        abx                     ; X = base + y*40 + x>>2
        ldb   ,s+               ; B = x, pop
        andb  #1
        lsrb                    ; carry = x bit0 (1 => low nibble)
        rts

* ---------------------------------------------------------------------------
* PlotPixel — In: A=y, B=x, sf_color=colour. RMW one nibble.
* Clobbers A,B,D,X. Preserves U,Y.
* ---------------------------------------------------------------------------
PlotPixel
        bsr   SF_PixelAddr
        bcs   @low
        lda   ,x                ; high nibble target
        anda  #$0F              ; keep low (neighbour)
        pshs  a
        lda   sf_color
        lsla
        lsla
        lsla
        lsla
        ora   ,s+
        sta   ,x
        rts
@low
        lda   ,x
        anda  #$F0              ; keep high (neighbour)
        ora   sf_color
        sta   ,x
        rts

* ---------------------------------------------------------------------------
* ErasePixel — In: A=y, B=x. Clear this pixel's nibble to 0 (RMW).
* Clobbers A,B,D,X. Preserves U,Y.
* ---------------------------------------------------------------------------
ErasePixel
        bsr   SF_PixelAddr
        bcs   @low
        lda   ,x
        anda  #$0F              ; clear high, keep low
        sta   ,x
        rts
@low
        lda   ,x
        anda  #$F0              ; clear low, keep high
        sta   ,x
        rts
```

INCLUDE it in `main.asm` routines section, after gfxlock, before the trailer:
```asm
        INCLUDE "./engine/graphics/buffer/gfxlock.asm"
        INCLUDE "./global/starfield.asm"
        INCLUDE "./global/global-trailer-includes.asm"
```

- [ ] **Step 2: Add a temporary plot-test to `gamemode.render`**

Replace the empty `gamemode.render` body with (guarded by `PLOT_TEST`):
```asm
gamemode.render
 IFDEF PLOT_TEST
        lda   #1
        sta   sf_color
        lda   #10               ; y=10
        ldb   #0                ; x=0  -> bank A, high nibble
        jsr   PlotPixel
        lda   #2
        sta   sf_color
        lda   #10
        ldb   #1                ; x=1  -> bank A, same byte, low nibble
        jsr   PlotPixel
        lda   #3
        sta   sf_color
        lda   #10
        ldb   #2                ; x=2  -> bank B, high nibble
        jsr   PlotPixel
 ENDC
        _main.render.return
```

- [ ] **Step 3: Build with PLOT_TEST**

Temporarily set in `config-linux.properties`:
```properties
builder.lwasm.define=boot_color_gr=$00,boot_color_b=$00,PLOT_TEST=1
```
Run:
```bash
cd game-projects/starfield && bash build-linux.sh
```
Expected: builds, `dist/starfield.fd` produced.

- [ ] **Step 4: Verify plotted pixels in TOJE**

```
[boot via the TOJE recipe in Global Constraints: load_cartridge starfield.rom -> run_frames n=120 -> type_keys ["1F"]]
mcp__toje__run_frames { "n": 120 }
mcp__toje__screenshot { "path": "/tmp/sf-plot.png" }
```
Inspect the top-left of `/tmp/sf-plot.png`:
```bash
python3 -c "
from PIL import Image
im=Image.open('/tmp/sf-plot.png').convert('RGB'); w,h=im.size; print('size',w,h)
# BM16 160px may render at 320 (doubled). Sample a small span at y=10.
print([im.getpixel((x,10)) for x in range(0,10)])"
```
Expected: three adjacent bright pixels near the top-left corner — mid-grey (~158), light-grey (~219), white (~255) — in that left-to-right order (allowing for a horizontal ×2 scale in the render), rest black. This confirms bank/nibble math AND palette-index→colour mapping.

- [ ] **Step 5: Remove the temporary plot-test**

Revert the define in `config-linux.properties`:
```properties
builder.lwasm.define=boot_color_gr=$00,boot_color_b=$00
```
Delete the `IFDEF PLOT_TEST ... ENDC` block, leaving:
```asm
gamemode.render
        _main.render.return
```
Rebuild:
```bash
cd game-projects/starfield && bash build-linux.sh
```
Expected: builds clean, black screen again.

- [ ] **Step 6: Commit**

```bash
cd /home/robin/github/wide-dot/thomson-to8-game-engine
git add game-projects/starfield
git commit -m "feat(starfield): BM16 PlotPixel/ErasePixel primitive, verified in TOJE"
```

---

## Task 3: Star data + StarfieldInit + static render (both erase-lists)

Seed 72 stars (array-of-structs) and render them (erase-list build + plot) without motion. Proves data layout, per-layer colours, and that render writes the right pixel count and records erase entries.

**Files:**
- Modify: `game-projects/starfield/global/starfield.asm` (struct equates, data, `StarfieldInit`, `StarfieldRender`)
- Modify: `game-projects/starfield/game-mode/00/main.asm` (call `StarfieldInit`; add `jsr StarfieldRender` to MainLoop)

**Interfaces:**
- Consumes: `SF_PixelAddr`, `sf_color` (Task 2); `_rnda` macro + `InitRNG`/`RandomNumber` (engine); `gfxlock.backBuffer.id` (engine byte 0/1 = current back page).
- Produces:
  - Struct `star_data` = `NUM_STARS × st_size` records: `st_x`(word,8.8), `st_y`(byte), `st_col`(byte 1..3), `st_spd`(word); `st_size=6`.
  - Erase lists `erase_0`/`erase_1` = `NUM_STARS × er_size` records: `er_addr`(word), `er_mask`(byte); `er_size=3`.
  - `StarfieldInit` — seeds stars, clears both erase-lists, seeds RNG. No register inputs. Clobbers A,B,D,X,U.
  - `StarfieldRender` — erases `erase_[backBuffer.id]`, plots all stars, records new entries. No register inputs. Clobbers A,B,D,X,U,Y. Must run AFTER `jsr WaitVBL` (back buffer mounted at $A000/$C000).

- [ ] **Step 1: Add struct equates + data tables to `global/starfield.asm`**

Insert after the `sf_color fcb 0` line:

```asm
STARS_PER_LAYER equ 24
NUM_LAYERS      equ 3
NUM_STARS       equ STARS_PER_LAYER*NUM_LAYERS   ; 72

; --- star record layout ---
st_x    equ 0                   ; word, 8.8 fixed x, range [0, 160*256)
st_y    equ 2                   ; byte, 0..199
st_col  equ 3                   ; byte, engine colour 1..3
st_spd  equ 4                   ; word, 8.8 speed
st_size equ 6

; --- erase entry layout ---
er_addr equ 0                   ; word, plotted VRAM byte address
er_mask equ 2                   ; byte, AND-mask to erase its nibble ($0F/$F0)
er_size equ 3

; --- per-layer constants (index 0=slow,1=mid,2=fast) ---
sf_layer_speed  fdb  $0100,$0200,$0400
sf_layer_color  fcb  1,2,3

; --- RAM (fill, NOT rmb — see Global Constraints: rmb emits no bytes and
;     shifts every later routine one byte early in the loaded binary) ---
star_data fill 0,NUM_STARS*st_size
erase_0   fill 0,NUM_STARS*er_size
erase_1   fill 0,NUM_STARS*er_size   ; MUST stay contiguous after erase_0
```

- [ ] **Step 2: Write `StarfieldInit`**

Append to `global/starfield.asm`:

```asm
* ---------------------------------------------------------------------------
* StarfieldInit — seed all stars (3 contiguous layer blocks), clear erase
* lists, seed RNG. Clobbers A,B,D,X,U.
* ---------------------------------------------------------------------------
StarfieldInit
        jsr   InitRNG
        ldu   #star_data
        clrb                     ; B = layer 0..2
@layer
        pshs  b                  ; [S]=layer
        lslb                     ; word index into speed table
        ldx   #sf_layer_speed
        ldd   b,x
        std   @spd               ; stash layer speed
        ldb   ,s                 ; layer
        ldx   #sf_layer_color
        lda   b,x
        sta   @col               ; stash layer colour
        lda   #STARS_PER_LAYER
        sta   @cnt
@star
        _rnda 0,159              ; A = pixel x 0..159
        sta   st_x,u             ; hi byte
        clr   st_x+1,u           ; lo byte = 0
        _rnda 0,199              ; A = y 0..199
        sta   st_y,u
        lda   @col
        sta   st_col,u
        ldd   @spd
        std   st_spd,u
        leau  st_size,u
        dec   @cnt
        bne   @star
        puls  b                  ; layer
        incb
        cmpb  #NUM_LAYERS
        blo   @layer
; clear both erase lists (er_addr=0 => erase pass skips them first frame)
        ldx   #erase_0
@clr
        clr   ,x+
        cmpx  #erase_1+NUM_STARS*er_size
        blo   @clr
        rts
@spd    fdb   0
@col    fcb   0
@cnt    fcb   0
```

- [ ] **Step 3: Write `StarfieldRender`**

Append to `global/starfield.asm`:

```asm
* ---------------------------------------------------------------------------
* StarfieldRender — erase this page's old pixels, plot current stars, record
* new erase entries. Runs after jsr WaitVBL (back buffer mounted
* at $A000/$C000). Clobbers A,B,D,X,U,Y.
* ---------------------------------------------------------------------------
StarfieldRender
        lda   gfxlock.backBuffer.id
        bne   @page1
        ldu   #erase_0
        bra   @go
@page1
        ldu   #erase_1
@go
        stu   @elist
; --- erase pass ---
        ldb   #NUM_STARS
@eloop
        ldx   er_addr,u          ; stored addr (0 => nothing yet)
        beq   @enext
        lda   er_mask,u
        anda  ,x                 ; keep the OTHER nibble, clear this one
        sta   ,x
@enext
        leau  er_size,u
        decb
        bne   @eloop
; --- plot pass ---
        ldu   #star_data
        ldy   @elist
        ldb   #NUM_STARS
@ploop
        lda   st_col,u
        sta   sf_color
        lda   st_y,u             ; A = y
        pshs  b                  ; save counter (SF_PixelAddr clobbers B)
        ldb   st_x,u             ; B = x hi (pixel x)
        jsr   SF_PixelAddr       ; X=addr, C=1 if low nibble
        bcs   @low
        lda   ,x                 ; high nibble
        anda  #$0F
        pshs  a
        lda   sf_color
        lsla
        lsla
        lsla
        lsla
        ora   ,s+
        sta   ,x
        lda   #$0F               ; erase-mask: keep low, clear high
        bra   @rec
@low
        lda   ,x
        anda  #$F0
        ora   sf_color
        sta   ,x
        lda   #$F0               ; erase-mask: keep high, clear low
@rec
        stx   er_addr,y
        sta   er_mask,y
        puls  b                  ; restore counter
        leau  st_size,u
        leay  er_size,y
        decb
        bne   @ploop
        rts
@elist  fdb   0
```

- [ ] **Step 4: Wire into `main.asm`**

After `_palette.show`, and add the render call to the existing `MainLoop`
(the mode uses the WaitVBL loop established in Tasks 1–2 — there is no
`gamemode.render` / `_main.*` wiring):
```asm
        _palette.set #Pal_starfield
        _palette.show
        jsr   StarfieldInit

MainLoop
        jsr   WaitVBL                  ; flips buffers, mounts back buffer at $A000/$C000
        jsr   StarfieldRender
        bra   MainLoop
```

- [ ] **Step 5: Build**

Run:
```bash
cd game-projects/starfield && bash build-linux.sh
```
Expected: clean build, `dist/starfield.fd`. Fix any lwasm errors (label typos, offset-register misuse) before continuing.

- [ ] **Step 6: Verify 72 static stars in TOJE**

```
[boot via the TOJE recipe in Global Constraints: load_cartridge starfield.rom -> run_frames n=120 -> type_keys ["1F"]]
mcp__toje__run_frames { "n": 200 }
mcp__toje__screenshot { "path": "/tmp/sf-static.png" }
```
Read `/tmp/sf-static.png` — expected ~72 scattered single pixels in three greys on black. Count non-black pixels:
```bash
python3 -c "
from PIL import Image
im=Image.open('/tmp/sf-static.png').convert('RGB'); px=im.load(); w,h=im.size
n=sum(1 for y in range(h) for x in range(w) if px[x,y]!=(0,0,0))
print('nonblack~',n,'size',(w,h))"
```
Expected: a count near 72 (≈144 if BM16 renders ×2 horizontally). Two screenshots several frames apart give the **same** positions (no motion yet).

- [ ] **Step 7: Commit**

```bash
cd /home/robin/github/wide-dot/thomson-to8-game-engine
git add game-projects/starfield
git commit -m "feat(starfield): 72 static stars (struct), per-layer colour, erase-list recording"
```

---

## Task 4: Motion + wrap (StarfieldUpdate) — full parallax

Advance stars each frame and wrap; with the per-page erase-lists this yields smooth, smear-free parallax.

**Files:**
- Modify: `game-projects/starfield/global/starfield.asm` (add `StarfieldUpdate`)
- Modify: `game-projects/starfield/game-mode/00/main.asm` (add `jsr StarfieldUpdate` to MainLoop)

**Interfaces:**
- Consumes: `star_data` struct fields `st_x`/`st_spd`/`st_y` (Task 3); `_rnda` (engine).
- Produces: `StarfieldUpdate` — advances every star's 8.8 x by its speed; on borrow past 0, wraps (`x += 160.0`) with a fresh random y. No register inputs. Clobbers A,B,D,X,U.

- [ ] **Step 1: Write `StarfieldUpdate`**

Append to `global/starfield.asm`:

```asm
* ---------------------------------------------------------------------------
* StarfieldUpdate — advance each star left by its speed (8.8). Wrap at x<0.
* Clobbers A,B,D,X,U.
* ---------------------------------------------------------------------------
* The loop is bounded by the U pointer, NOT a counter in B: `ldd st_x,u` loads
* D=A:B and would destroy a counter held in B (that walks U past star_data and
* crashes). StarfieldRender may keep its counter in B only because its erase
* pass touches A/X only and its plot pass saves B around SF_PixelAddr.
StarfieldUpdate
        ldu   #star_data
@loop
        ldd   st_x,u
        subd  st_spd,u           ; x -= speed; carry set on borrow (x<speed)
        bcc   @store
; wrapped past left edge: x += 160.0, new random y
        addd  #160*256
        std   st_x,u
        _rnda 0,199              ; A = new y (clobbers D; x is already stored)
        sta   st_y,u
        bra   @next
@store
        std   st_x,u
@next
        leau  st_size,u
        cmpu  #star_data+NUM_STARS*st_size
        blo   @loop
        rts
```

- [ ] **Step 2: Wire into `main.asm`**

Add the update call to `MainLoop`, before the render (advance positions once
per frame, then draw them):
```asm
MainLoop
        jsr   WaitVBL
        jsr   StarfieldUpdate
        jsr   StarfieldRender
        bra   MainLoop
```

- [ ] **Step 3: Build**

Run:
```bash
cd game-projects/starfield && bash build-linux.sh
```
Expected: clean build.

- [ ] **Step 4: Verify motion + no smearing in TOJE**

```
[boot via the TOJE recipe in Global Constraints: load_cartridge starfield.rom -> run_frames n=120 -> type_keys ["1F"]]
mcp__toje__run_frames { "n": 60 }
mcp__toje__screenshot { "path": "/tmp/sf-a.png" }
mcp__toje__run_frames { "n": 30 }
mcp__toje__screenshot { "path": "/tmp/sf-b.png" }
```
Read both PNGs. Expected:
- Stars moved leftward between A and B; white fastest, dark-grey slowest (visible parallax).
- Non-black pixel count essentially constant between A and B (erase-lists clean both pages — no accumulation):
```bash
python3 -c "
from PIL import Image
def n(f):
    im=Image.open(f).convert('RGB'); px=im.load(); w,h=im.size
    return sum(1 for y in range(h) for x in range(w) if px[x,y]!=(0,0,0))
print('A',n('/tmp/sf-a.png'),'B',n('/tmp/sf-b.png'))"
```
Expected: A ≈ B (small variance from wrap OK; must NOT grow). Then:
```
mcp__toje__run_frames { "n": 500 }
mcp__toje__screenshot { "path": "/tmp/sf-c.png" }
```
Count again — still in the same range (no long-term smear).

- [ ] **Step 5: Commit**

```bash
cd /home/robin/github/wide-dot/thomson-to8-game-engine
git add game-projects/starfield
git commit -m "feat(starfield): star motion + edge wrap, smear-free double-buffer parallax"
```

---

## Task 5: Polish pass + final verification

Confirm the three planes read as distinct depths, tune if needed, record a final reference screenshot, and verify long-run stability.

**Files:**
- Modify (only if tuning needed): `game-projects/starfield/global/starfield.asm` (`STARS_PER_LAYER`, `sf_layer_speed`)

**Interfaces:** none new.

- [ ] **Step 1: Full-run visual check**

```
[boot via the TOJE recipe in Global Constraints: load_cartridge starfield.rom -> run_frames n=120 -> type_keys ["1F"]]
mcp__toje__run_frames { "n": 400 }
mcp__toje__screenshot { "path": "/tmp/sf-final.png" }
```
Read `/tmp/sf-final.png`. Checklist: three brightness tiers clearly visible; white stars visibly faster than dark ones across frames; no flicker, tearing, or stray/stuck edge pixels.

- [ ] **Step 2: (Optional) tune**

If parallax feels weak, adjust `sf_layer_speed` (e.g. `$0080,$0180,$0400`) or `STARS_PER_LAYER`. Rebuild and re-verify Step 1. Keep changes minimal.

- [ ] **Step 3: Long-run stability check**

```
mcp__toje__run_frames { "n": 2000 }
mcp__toje__screenshot { "path": "/tmp/sf-long.png" }
mcp__toje__read_registers
```
Re-count non-black pixels (Task 4 Step 4 method): still ~72 (×render factor), no accumulation. `read_registers`: PC still live in the mode loop.

- [ ] **Step 4: Commit**

```bash
cd /home/robin/github/wide-dot/thomson-to8-game-engine
git add game-projects/starfield
git commit -m "feat(starfield): final parallax tuning and stability verification"
```

---

## Self-Review notes

- **Spec coverage:** §2 rendering (approach B, per-page erase-lists) → Tasks 3–4; §3 module interface (`StarfieldInit/Update/Render`, `PlotPixel/ErasePixel`) → Tasks 2–4; §4 data layout (now array-of-structs, cleaner than the spec's parallel arrays — same fields) → Task 3; §5 palette → Task 1; §6 game mode/loop → Task 1; §7 build → Task 1; §8 testing → TOJE steps in every task; §9 gotchas → Global Constraints + render wired strictly inside `_gfxlock.on/off`.
- **Deviation from spec §4:** the plan uses array-of-structs (`star_data`, 6-byte records) instead of parallel arrays. This is a deliberate simplification — a single walking `U` pointer avoids per-array offset computation and the illegal `reg,reg` indexing that parallel arrays invite. Fields and semantics are identical.
- **RNG:** `InitRNG` (seeds from `$E7C6`) is called once in `StarfieldInit`; without it `RandomNumber` returns 0 forever (all stars pile on one point). `_rnda` clobbers B, so `StarfieldUpdate` saves the loop counter around it.
- **Register discipline:** `SF_PixelAddr` preserves U and Y, so `StarfieldRender` can keep the star pointer in U and the erase-list pointer in Y across the call; the loop counter in B is saved on the stack around it.
- **Type consistency:** struct offsets (`st_x/st_y/st_col/st_spd`, `er_addr/er_mask`) and sizes (`st_size=6`, `er_size=3`) are defined once in Task 3 Step 1 and used identically in Tasks 3–4. `sf_color`/`SF_PixelAddr` signatures match between Task 2 (definition) and Task 3 (use).
```
