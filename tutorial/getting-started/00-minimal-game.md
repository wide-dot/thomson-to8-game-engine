# Step 00: Boot & Minimal Game Structure

**Objective**: Create a playable game that responds to input and renders a sprite.

**Time**: 45 minutes

**What you'll build**: A game with one sprite you can move with the joypad.

---

## Subsystems in Activation Order

This step activates 5 core subsystems in sequence:

1. **Boot** — RAM initialization and bootloader
2. **Graphics** — Display mode setup and rendering
3. **Object Management** — Sprite lifecycle and positioning
4. **Joypad Input** — Read directional pad and button states
5. **Collision Detection** — Boundary checking

Every Thomson TO8 game follows this same pattern. Once you understand this sequence, you'll be able to tackle any game.

---

## Walkthrough: The Game Loop

The core architecture is simple:

```
INIT PHASE (runs once):
  1. Initialize memory and graphics
  2. Create game objects (sprites)
  3. Set up input hardware

LOOP PHASE (runs every frame):
  1. Read joypad input
  2. Update sprite positions based on input
  3. Check boundaries and collisions
  4. Render frame
  5. Repeat
```

This three-step loop (input → update → render) is the same loop used in Goldorak, R-Type, and every modern game engine.

### Why This Order?

- **Boot first**: You can't render without initialized memory and graphics hardware
- **Graphics before objects**: Objects need a screen to draw on
- **Objects before input**: You need sprites to move before you can accept input
- **Input → Update → Render**: This order prevents visual glitches and ensures responsive gameplay

### The 6809 Stack

The TO8 uses a Motorola 6809 processor. When we say "stack," we mean:
- Register `S` (stack pointer) points to RAM where temporary values live
- `jsr` (jump subroutine) pushes the return address on the stack
- `rts` (return from subroutine) pops and jumps back

Stack grows downward in memory. Each `jsr` costs 3 bytes (the return address). In tight code, you'll see `lbsr` for long calls, which costs 4 bytes.

---

## Code Template: Copy & Modify

The minimal game template lives in `tutorial/templates/minimal-game/` and provides a complete project scaffold.

**To get started:**

1. Create a working directory:
   ```bash
   mkdir my-first-game
   cd my-first-game
   ```

2. Copy the template:
   ```bash
   cp -r /path/to/thomson-to8-game-engine/tutorial/templates/minimal-game/* .
   ```

3. You'll see this structure:
   ```
   my-first-game/
   ├── main.asm              # Main game code (edit this)
   ├── config-linux.properties
   ├── global/
   │   ├── global-equates.asm
   │   └── global-variables.asm
   └── Makefile
   ```

### Template File Organization

If you don't have the template yet, here's the minimal boilerplate structure to create it manually:

**main.asm**:
```asm
        org $6100
        jsr InitGlobals             ; Initialize memory
        jsr InitGraphics            ; Set up display
        jsr CreateSprites           ; Allocate sprite table
        jsr InitJoypads             ; Enable input
GameLoop:
        jsr ReadJoypad
        jsr UpdateSprites
        jsr RenderFrame
        bra GameLoop
```

**global/global-equates.asm**:
```asm
* Display constants
ScreenWidth:    equ 320
ScreenHeight:   equ 200
ScreenBase:     equ $4000

* Sprite table (max 32 sprites)
SpriteTable:    equ $5000
SpriteStride:   equ 16
MaxSprites:     equ 32

* Joypad input
JoypadPort_A:   equ $E7CC           ; Directional pad
JoypadPort_B:   equ $E7CD           ; Action buttons
```

**global/global-variables.asm**:
```asm
        org $0400
GameState:      rmb 256             ; Game state and variables
PlayerSprite:   rmb 16              ; Player sprite structure
BulletTable:    rmb 32*16           ; Up to 32 bullets
EnemyTable:     rmb 16*16           ; Up to 16 enemies
```

4. Build the game:
   ```bash
   togen ./config-linux.properties
   ```

5. Run it:
   ```bash
   to8 dist/my-first-game.fd
   ```

You'll see a red square on screen. Use the joypad to move it around. That's your first game.

---

## Modifications: What Each Line Does

Open `main.asm`. The structure looks like this:

```asm
        org $6100                    ; Code starts at address 0x6100

        jsr InitGlobals             ; Line 3: Initialize memory
        jsr InitGraphics            ; Line 4: Set up display mode
        jsr CreateSprites           ; Line 5: Create first sprite
        jsr InitJoypads             ; Line 6: Enable joypad reading
        jsr WaitVBL                 ; Line 7: Wait for screen refresh

* Main game loop starts here
GameLoop:
        jsr ReadJoypad              ; Read input from joypad
        jsr UpdateSprites           ; Move sprites based on input
        jsr CheckBoundaries         ; Don't let sprite leave screen
        jsr RenderFrame             ; Draw everything
        bra GameLoop                ; Loop forever
```

### Key Lines to Understand

**Line 3 - `InitGlobals`**: Sets up memory addresses for graphics, sprite data, and RAM variables. This must happen before anything else.

**Line 4 - `InitGraphics`**: Tells TO8 which display mode to use. The template uses "mode 5" (320x200 pixels, 16 colors). You can change this to:
- Mode 0: 320x200 black & white (2 colors)
- Mode 1: 320x200 4 colors
- Mode 4: 160x200 16 colors
- Mode 5: 320x200 16 colors (default)

Changing modes affects sprite size and palette. For now, stick with mode 5.

**Line 5 - `CreateSprites`**: Creates the first sprite. In 6809 asm:

```asm
CreateSprites:
        ldy   #SpriteTable          ; Y = address of sprite table
        ldx   #64                   ; X = 64 (starting X position)
        lda   #100                  ; A = 100 (starting Y position)
        std   x_pos,y               ; Store both as a 16-bit pair
        lda   #1                    ; A = 1 (sprite is alive)
        sta   sprite_active,y       ; Mark sprite active
        rts
```

This allocates one sprite at (64, 100). Each sprite has:
- `x_pos` / `y_pos` — 8-bit position coordinates
- `sprite_active` — 1 = alive, 0 = despawned
- `frame` — animation frame number (0-based)

**Line 6 - `InitJoypads`**: Enables the joypad port. TO8 has 2 joypad ports (port A and B). The template reads port A by default.

**Line 7 - `WaitVBL`**: Waits for vertical blanking (screen refresh). This prevents flickering by syncing updates to the display's refresh cycle. VBL happens 50 times per second (PAL) or 60 times per second (NTSC).

---

## The Main Loop Explained

### Reading Input

In the main loop, `ReadJoypad` does this:

```asm
ReadJoypad:
        ldx   #$A7E0                ; Joypad port A address
        lda   ,x                    ; Read joypad state
        sta   joypad_state          ; Save for other routines
        rts
```

The joypad state is an 8-bit byte where each bit represents a button:

```
Bit 7: Fire button
Bit 6: Button B
Bit 5: Button A
Bits 4-7: Directions (up, down, left, right)
```

### Updating Positions

`UpdateSprites` reads the joypad state and moves the sprite:

```asm
UpdateSprites:
        lda   joypad_state
        bita  #$08                  ; Test left directional bit
        beq   not_left
        dec   x_pos                 ; Move left (decrease X)
not_left:
        bita  #$04                  ; Test right directional bit
        beq   not_right
        inc   x_pos                 ; Move right (increase X)
not_right:
        rts
```

Notice: We use `bita` (bit test accumulator) to check individual bits without destroying the value. Then `beq` (branch if equal to zero) skips if the bit wasn't set.

### Checking Boundaries

`CheckBoundaries` prevents sprites from leaving the screen:

```asm
CheckBoundaries:
        lda   x_pos
        cmpa  #320                  ; Max X for mode 5
        bls   x_ok                  ; If less-than-or-equal, skip
        lda   #319                  ; Clamp to 319
        sta   x_pos
x_ok:
        rts
```

This is simple collision detection: if X exceeds screen width (320 pixels in mode 5), clamp it to the maximum valid value (319).

### Rendering

`RenderFrame` calls the graphics system to draw all active sprites:

```asm
RenderFrame:
        jsr   ClearScreen           ; Clear background
        ldy   #SpriteTable
render_loop:
        lda   sprite_active,y
        beq   sprite_done
        jsr   DrawSprite            ; Draw one sprite
        leay  SpriteStride,y        ; Move to next sprite
        bra   render_loop
sprite_done:
        rts
```

Each sprite has a fixed memory layout (stride). The loop iterates through the sprite table, drawing each active sprite.

---

## What's Next

In Step 01, you'll:
- Add multiple sprites with different graphics
- Implement animation (cycling through frames)
- See how r-type and Goldorak handle complex scenes with 30+ sprites

The architecture stays the same. You'll just add more sprites to the loop and add frame-cycling logic.

---

## Deep Dive: API Reference Links

For detailed information on each subsystem:

- **Boot System** → `api-reference/boot-api.md`
  - Memory initialization
  - Bootloader behavior
  - RAM vs. ROM setup

- **Graphics API** → `api-reference/graphics-api.md`
  - Display modes (0-5)
  - Screen buffer layout
  - Palette management
  - Sprite rendering primitives

- **Object Management API** → `api-reference/object-management-api.md`
  - Sprite table structure
  - Object lifecycle
  - State machine patterns
  - Entity pooling

- **Joypad API** → `api-reference/joypad-api.md`
  - Port A and Port B addressing
  - Button bit definitions
  - Debouncing techniques
  - Multi-player input handling

- **Collision Detection API** → `api-reference/collision-api.md`
  - Bounding box collisions
  - Pixel-perfect collision masks
  - Collision callbacks
  - Performance optimization

---

## Troubleshooting

**Issue**: Build fails with "undefined symbol"
- **Cause**: Missing `togen` or incorrect config path
- **Fix**: Run `togen ./config-linux.properties` from the game directory

**Issue**: Emulator won't load .fd file
- **Cause**: Corrupted build or missing RetroArch
- **Fix**: Check `logs/` for build errors. Ensure Theodore TO8 core is installed: `retroarch --list-cores | grep theodore`

**Issue**: Sprite doesn't move
- **Cause**: Joypad input not being read
- **Fix**: Check that `InitJoypads` is called before the main loop. Verify joypad port address ($A7E0) is correct for your machine.

**Issue**: Screen flickers
- **Cause**: Rendering without waiting for VBL
- **Fix**: Ensure `WaitVBL` is called once per frame, right before or after `RenderFrame`

---

## Summary

You've learned:

1. **Boot sequence**: Always init memory, graphics, objects, then input
2. **Game loop**: Input → Update → Render, repeat forever
3. **Joypad input**: Each button is a bit in a byte; test with `bita`
4. **Boundary checking**: Simple collision is just min/max clamping
5. **Sprite rendering**: Loop through sprite table, draw each active sprite

By the end of this step, you have a working game. It's minimal, but it demonstrates every core system. Congratulations!

**Ready?** Proceed to Step 01: Sprite System.
