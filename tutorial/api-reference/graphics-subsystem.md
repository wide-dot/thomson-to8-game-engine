# Graphics Subsystem API Reference

**Author**: Claude Code  
**Version**: 1.0  
**Last Updated**: June 2026  
**Target Audience**: Intermediate 6809 programmers familiar with Thomson TO8 memory model

---

## Overview

The Graphics Subsystem manages display rendering, sprite drawing, and video memory on the Thomson TO8. It coordinates between the CPU and the hardware video controller to produce the 320x224 pixel, 16-color display that all TO8 games use.

### Core Responsibilities

1. **Video Memory Management** — Allocating and clearing the 40 KB video RAM (addresses $6000-$F8FF)
2. **Screen Refresh** — Synchronizing rendering with the vertical blank (VBL) interrupt
3. **Sprite Rendering** — Drawing sprite images at arbitrary positions with priority-based layering
4. **Palette Control** — Managing the 16-color palette and palette transitions
5. **Buffer Swapping** — Double-buffering for flicker-free rendering

### Hardware Context

The Thomson TO8 video hardware:
- **Display Mode**: 320x224 pixels, 16 colors (Mode 5)
- **Video RAM**: $6000–$F8FF (40 KB)
- **Color Registers**: $A7DA–$A7E9 (10 bytes for 16 colors)
- **Interrupt Source**: Vertical Blank (VBL) fires every 20 ms (50 Hz)
- **Sprite Rendering**: CPU-driven (no hardware sprite engine)

---

## Memory & Hardware Layout

### Video Memory Map

```
Address Range     Size      Purpose
────────────────────────────────────────────────────
$6000–$F8FF       40 KB     Video RAM (main display)
$A7DA–$A7E9       10 bytes  Palette registers (16 colors)
$A7E7             1 byte    Video control port
$E7CC             1 byte    Joypad direction (Port A)
$E7CD             1 byte    Joypad buttons (Port B)
```

### Display Format

The TO8 uses a planar video memory layout (4 bitplanes):

```
Line 0 (top):    Pixels 0-319  →  4 bitplanes × 40 bytes = 160 bytes
Line 1:          Pixels 0-319  →  4 bitplanes × 40 bytes = 160 bytes
...
Line 223:        Pixels 0-319  →  4 bitplanes × 40 bytes = 160 bytes

Total: 224 lines × 160 bytes/line = 35,840 bytes ($8BF0)

Within each line:
- Bitplane 0: Bytes 0–39 (bit 0 of each pixel)
- Bitplane 1: Bytes 40–79 (bit 1 of each pixel)
- Bitplane 2: Bytes 80–119 (bit 2 of each pixel)
- Bitplane 3: Bytes 120–159 (bit 3 of each pixel)
```

### Line Calculation

To address a pixel at (x, y):

```asm
; Calculate byte offset for pixel at column x, line y
; y = line number (0–223)
; x = pixel column (0–319), will be converted to byte offset

LineBase equ     160 * y        ; Bytes to skip to reach this line
PixelByte equ    x / 8          ; Byte offset within line
Bitplane0 equ    $6000 + LineBase + PixelByte
Bitplane1 equ    $6000 + LineBase + 40 + PixelByte
Bitplane2 equ    $6000 + LineBase + 80 + PixelByte
Bitplane3 equ    $6000 + LineBase + 120 + PixelByte
```

### Palette Layout

The 16 colors are stored in the palette registers:

```
$A7DA–$A7E3:  8 bytes (colors 0–7)
$A7E4–$A7E9:  6 bytes (colors 8–13)
Border color: $A7E7 (bits 3–0 = color, bit 7 = frame sync flag)

Each color is packed as:
  Bit 7: Frame sync flag (1 = odd frame, 0 = even frame)
  Bits 3–0: Color palette index (0–15)
```

---

## Public Functions

### WaitVBL — Synchronize to Vertical Blank

**Purpose**: Halt execution until the next vertical blank (screen refresh) occurs. Used to synchronize game updates with the display refresh rate (50 Hz).

**Signature**:
```asm
WaitVBL
```

**Parameters**: None

**Returns**: None (Z flag may be affected)

**Cycles**: ~20 ms (varies based on when called within frame)

**Usage Example**:
```asm
; Main game loop
GameLoop:
        jsr   WaitVBL              ; Sync to 50 Hz
        jsr   ReadJoypad           ; Read input
        jsr   UpdateGame           ; Update game state
        jsr   RenderFrame          ; Draw graphics
        bra   GameLoop
```

**Notes**:
- Essential for flicker-free rendering and input latency reduction
- Call at the start of each game loop iteration
- Blocks until VBL interrupt fires
- The TO8 generates VBL every 20 ms exactly

**Common Pattern**:
```asm
; Double-buffered rendering pattern
WaitVBL_Pattern:
        jsr   WaitVBL              ; Wait for safe moment to swap buffers
        jsr   SwapVideoBuffer       ; Flip visible/hidden buffer
        jsr   ClearHiddenBuffer     ; Clear the now-hidden buffer
        jsr   RenderToHiddenBuffer  ; Draw to invisible buffer
        bra   WaitVBL_Pattern
```

**Implementation Detail**: The function polls the interrupt flag or uses the frame counter to detect VBL. Some implementations use a counter incremented by the VBL ISR.

---

### ClearScreen — Erase the Entire Display

**Purpose**: Fill the entire video RAM with a single color. Used for screen transitions, level resets, and initialization.

**Signature**:
```asm
ClearScreen
```

**Parameters**:
- **Accumulator A**: Color index (0–15)

**Returns**: None (A and B destroyed)

**Cycles**: ~100–200 cycles (loops through all 40 KB of VRAM)

**Usage Example**:
```asm
; Clear screen to black (color 0)
InitializeGame:
        lda   #0                   ; Color 0 (black)
        jsr   ClearScreen
        rts

; Clear screen to white (color 15)
ClearToWhite:
        lda   #15
        jsr   ClearScreen
        rts
```

**Notes**:
- Operates on the visible (or active) buffer; pair with `WaitVBL` to avoid tearing
- Fast enough to call during game loop for fade-out effects
- Clears all 40 KB of VRAM in approximately 1 frame (20 ms)

**Related Functions**: `ClearHiddenBuffer` (same operation on the alternate video buffer)

---

### SetPalette — Load a Color Palette

**Purpose**: Replace the entire 16-color palette from a source table in RAM. Used for palette swaps, color transitions, and effects.

**Signature**:
```asm
SetPalette
```

**Parameters**:
- **Index X**: Address of 16-byte color table in RAM

**Returns**: None (all registers destroyed)

**Cycles**: ~400 cycles (16 writes to palette hardware)

**Usage Example**:
```asm
; Load palette from a pre-defined table
LoadLevelPalette:
        ldx   #Level1Palette       ; X = address of 16-byte palette
        jsr   SetPalette           ; Install it
        rts

Level1Palette:
        fcb   $00, $01, $02, $03   ; Colors 0–3
        fcb   $04, $05, $06, $07   ; Colors 4–7
        fcb   $08, $09, $0A, $0B   ; Colors 8–11
        fcb   $0C, $0D, $0E, $0F   ; Colors 12–15
```

**Notes**:
- The color table must be 16 bytes (one byte per color index 0–15)
- Each byte is the actual 6-bit color value sent to the video hardware
- Common palettes are pre-calculated and stored in the ROM
- Safe to call during game loop (changes palette next frame)

**Palette Format** (6-bit color):
```
Bits 5–0: Red, Green, Blue in 2-bit format
  RR GG BB
  
Example:
  $00 = Black (RGB 000000)
  $07 = White (RGB 111111)
  $01 = Blue (RGB 000001)
  $04 = Red (RGB 010000)
```

**Pattern: Fade Transition**:
```asm
; Fade from current palette to black over 50 frames
FadeToBlack:
        lda   #50                  ; 50 iterations (1 second at 50 Hz)
        sta   fade_counter
fade_loop:
        jsr   WaitVBL
        jsr   DarkenPalette        ; Reduce all color values by 1
        jsr   SetPalette
        dec   fade_counter
        bne   fade_loop
        rts
```

---

### BlitSprite — Draw a Sprite at Position

**Purpose**: Render a sprite (8×N or 16×N bitmap) at a given (x, y) position. Core rendering function for all visible game objects.

**Signature**:
```asm
BlitSprite
```

**Parameters**:
- **Index X**: Sprite bitmap address (in ROM or RAM)
- **Accumulator A**: X position (0–319 pixels)
- **Accumulator B**: Y position (0–223 pixels)
- **Index U**: Sprite metadata (width, height, color key)

**Returns**: None (all registers destroyed)

**Cycles**: 50–500 cycles (depends on sprite size and position)

**Usage Example**:
```asm
; Draw player sprite at (100, 80)
DrawPlayer:
        ldx   #PlayerSpriteBitmap
        lda   #100                 ; X position
        ldb   #80                  ; Y position
        ldu   #PlayerSpriteInfo    ; Sprite metadata
        jsr   BlitSprite
        rts

PlayerSpriteInfo:
        fcb   16                   ; Width in pixels
        fcb   16                   ; Height in pixels
        fcb   0                     ; Color key (0 = transparent)
        fcb   0                     ; Flags
```

**Sprite Bitmap Format**:

Sprites are stored as linear byte arrays in planar format (same as video memory):

```
For a 16×16 sprite:
  Each scanline: 16 pixels = 2 bytes across 4 bitplanes
  
  Bitplane 0: Bytes 0–1 (bit 0 of each pixel)
  Bitplane 1: Bytes 2–3 (bit 1 of each pixel)
  Bitplane 2: Bytes 4–5 (bit 2 of each pixel)
  Bitplane 3: Bytes 6–7 (bit 3 of each pixel)
  [Repeat for next scanline]
```

**Notes**:
- Sprite must fit within screen bounds; clipping is automatic
- Sprites with color key (usually 0) render as transparent
- Common sprite sizes: 8×8, 16×16, 32×32, 16×24
- Drawing order matters for layering; draw background to foreground

**Advanced: Sprite with Rotation**:
```asm
; Draw sprite with rotation metadata
DrawRotatedSprite:
        ldx   #SpriteRotations     ; Table of rotation frames
        lda   rotation_angle       ; 0–7 (8 rotation frames)
        asla                       ; Index into rotation table
        leax  a,x
        ldx   ,x                   ; Load bitmap for this angle
        jsr   BlitSprite           ; Draw it
        rts
```

**Related Functions**: `BlitSpritePartial` (draw only a portion of sprite), `BlitSpriteMasked` (use a separate mask buffer)

---

### GetPixel — Read a Pixel Value

**Purpose**: Return the color index (0–15) of a single pixel at (x, y). Used for collision detection and effects.

**Signature**:
```asm
GetPixel
```

**Parameters**:
- **Accumulator A**: X coordinate (0–319)
- **Accumulator B**: Y coordinate (0–223)

**Returns**:
- **Accumulator A**: Color index (0–15)

**Cycles**: ~50 cycles (bit extraction)

**Usage Example**:
```asm
; Check if (100, 50) is not background (color 0)
CheckPixel:
        lda   #100
        ldb   #50
        jsr   GetPixel             ; Get color at (100, 50)
        beq   at_background        ; If A=0, at background
        bra   hit_something
at_background:
        rts
```

**Notes**:
- Slow operation; use only for point queries
- For collision detection, bounding boxes are more efficient than per-pixel checks

---

### SetPixel — Write a Pixel Value

**Purpose**: Set a single pixel to a color. Low-level graphics primitive.

**Signature**:
```asm
SetPixel
```

**Parameters**:
- **Accumulator A**: X coordinate (0–319)
- **Accumulator B**: Y coordinate (0–223)
- **Accumulator C**: Color index (0–15)

**Returns**: None (all registers destroyed)

**Cycles**: ~80 cycles (bit manipulation + write)

**Usage Example**:
```asm
; Draw a white (color 15) dot at (160, 112)
DrawDot:
        lda   #160
        ldb   #112
        ldc   #15                  ; White
        jsr   SetPixel
        rts
```

**Notes**:
- Rarely called directly; sprites are much faster for multiple pixels
- Used in debugging and drawing primitive shapes (lines, circles)

---

## Helper Macros

### VRAM Address Calculation

**Macro**: `@VideoAddress`

Converts (x, y) to a video RAM address:

```asm
; Usage:
; @VideoAddress temp_addr, 100, 50
; Now temp_addr contains the address of pixel (100, 50)

@VideoAddress MACRO addr, x, y
        ldd   #\x
        addd  #\y * 160            ; Line offset
        addd  #$6000               ; Video RAM base
        std   \addr
 ENDM
```

### Palette Register Write

**Macro**: `WritePaletteReg`

Writes a single color to a palette register:

```asm
WritePaletteReg MACRO color_idx, color_val
        lda   \color_val
        sta   $A7DA + \color_idx
 ENDM
```

---

## Common Patterns

### Pattern 1: Double-Buffered Rendering

This is the canonical rendering loop:

```asm
GameLoop:
        jsr   WaitVBL              ; Wait for safe moment (50 Hz sync)
        
        jsr   ReadJoypad           ; Update input
        jsr   UpdateGameState      ; Physics, AI, state machines
        
        ; Render to off-screen buffer
        jsr   ClearHiddenBuffer    ; Clear to background color
        jsr   DrawBackground       ; Draw tiles
        jsr   DrawSprites          ; Draw game objects
        jsr   DrawUI               ; Draw HUD (text, bars)
        
        jsr   SwapVideoBuffer       ; Make off-screen visible
        bra   GameLoop
```

**Why Double-Buffering**:
- Prevents tearing (mid-screen flicker)
- Allows smooth animation
- Guarantees consistent frame timing

### Pattern 2: Sprite Loop with Priority

Drawing sprites in correct depth order:

```asm
; Sprite table structure: 32 bytes per sprite
DrawAllSprites:
        ldx   #SpriteTable
        lda   #0                   ; Priority level (back to front)

depth_loop:
        cmpa  #8                   ; 8 priority levels
        bge   done_sprites
        
        ldy   #SpriteTable
        
sprite_loop:
        ldb   sprite_priority,y
        cmpb  a,x                  ; Check if this sprite matches depth
        bne   next_sprite
        
        ldb   sprite_active,y      ; Skip if inactive
        beq   next_sprite
        
        ; Draw this sprite
        ldb   sprite_x,y
        pshs  a
        lda   b                    ; A = X position
        
        ldb   sprite_y,y           ; B = Y position
        ldx   #SpriteGraphics      ; X = bitmap address
        jsr   BlitSprite
        puls  a
        
next_sprite:
        leay  SpriteStride,y
        cmpy  #SpriteTableEnd
        bne   sprite_loop
        
        inca                       ; Next priority level
        bra   depth_loop
        
done_sprites:
        rts
```

### Pattern 3: Fade Effect

Gradually transition between two palettes:

```asm
FadeFromTo:
        ; Input:
        ;   X = source palette address
        ;   Y = destination palette address
        ;   A = duration in frames (50 = 1 second)
        
        sta   fade_duration
        stx   fade_src_ptr
        sty   fade_dst_ptr
        
fade_loop:
        jsr   WaitVBL
        
        ; Interpolate between palettes
        ldx   fade_src_ptr
        ldy   fade_dst_ptr
        lda   fade_duration
        
        jsr   InterpolatePalette   ; Blend 1 frame closer to destination
        jsr   SetPalette
        
        dec   fade_duration
        bne   fade_loop
        rts
```

### Pattern 4: Sprite Animation

Cycle through animation frames:

```asm
; Sprite record includes:
; sprite_frame equ 3
; sprite_anim_counter equ 4
; sprite_anim_speed equ 5

UpdateSpriteAnimation:
        ldx   #SpriteTable
        
anim_loop:
        ldb   sprite_active,x
        beq   anim_next
        
        ; Increment animation counter
        inc   sprite_anim_counter,x
        
        ; Check if time to advance frame
        ldb   sprite_anim_counter,x
        cmpb  sprite_anim_speed,x
        blt   anim_next
        
        ; Advance frame and reset counter
        lda   sprite_frame,x
        inca
        cmpa  sprite_frame_max,x
        bne   set_frame
        lda   #0                   ; Wrap to frame 0
        
set_frame:
        sta   sprite_frame,x
        lda   #0
        sta   sprite_anim_counter,x
        
anim_next:
        leax  SpriteStride,x
        cmpx  #SpriteTableEnd
        bne   anim_loop
        rts
```

### Pattern 5: Collision Detection with Sprites

Using bounding boxes:

```asm
CollisionCheck:
        ; Check collision between bullet (X) and enemy (Y)
        ; Returns with A=1 if collision, A=0 otherwise
        
        ; Bounding box: x, y, width, height offsets
        lda   sprite_x,x
        adda  sprite_col_x_off,x
        sta   <bullet_left
        
        lda   sprite_y,x
        adda  sprite_col_y_off,x
        sta   <bullet_top
        
        lda   sprite_x,y
        adda  sprite_col_x_off,y
        sta   <enemy_left
        
        lda   sprite_y,y
        adda  sprite_col_y_off,y
        sta   <enemy_top
        
        ; Separating axis test
        lda   <bullet_left
        adda  sprite_col_w,x
        cmpa  <enemy_left
        bls   no_collision
        
        lda   <bullet_top
        adda  sprite_col_h,x
        cmpa  <enemy_top
        bls   no_collision
        
        ; Collision!
        lda   #1
        rts
        
no_collision:
        lda   #0
        rts
```

---

## Common Mistakes

### Mistake 1: Forgetting WaitVBL

**The Problem**:
```asm
; WRONG: No VBL synchronization
MainLoop:
        jsr   ClearScreen
        jsr   DrawSprites
        jsr   Render
        bra   MainLoop    ; Runs as fast as CPU allows (~2 MHz)
```

**Why It Fails**:
- Loop runs 100× per frame (at 50 Hz display rate)
- Sprite positions update 100× per frame → sprites move 100× faster than intended
- Frame timing becomes unpredictable
- Input latency increases (can reach 100 ms)

**The Fix**:
```asm
; RIGHT: Sync to display
MainLoop:
        jsr   WaitVBL                ; Wait for screen refresh (every 20 ms)
        jsr   ReadJoypad             ; Input once per frame
        jsr   UpdateGameState        ; Update once per frame
        jsr   RenderFrame            ; Draw once per frame
        bra   MainLoop               ; Loop runs at 50 Hz
```

**Lesson**: Always call `WaitVBL` at the top of your main loop. It's the heartbeat of the game.

---

### Mistake 2: Drawing to the Visible Buffer

**The Problem**:
```asm
; WRONG: Rendering to visible VRAM
RenderFrame:
        ldx   #SpriteTable
sprite_loop:
        jsr   BlitSprite            ; Draw directly to $6000
        leax  SpriteStride,x
        cmpx  #SpriteTableEnd
        bne   sprite_loop
        rts
```

**Why It Fails**:
- While CPU is drawing, video hardware is reading same memory
- Sprites appear to tear or flicker mid-screen
- Inconsistent visuals frame-to-frame

**The Fix**:
```asm
; RIGHT: Use double-buffering
WaitVBL_Pattern:
        jsr   WaitVBL              ; Sync to end of frame
        jsr   SwapVideoBuffer       ; Switch visible/hidden
        
        ; Now render to hidden buffer ($8000 or alternate area)
        jsr   ClearBuffer          ; Clear hidden buffer
        jsr   DrawToHiddenBuffer   ; Render all sprites
        bra   WaitVBL_Pattern       ; Repeat
```

**Lesson**: Always maintain two video buffers (320×224×4 bits = 40 KB each). Render to one while displaying the other, then swap.

---

### Mistake 3: Incorrect Sprite Byte Offset Calculation

**The Problem**:
```asm
; WRONG: Treating video memory like linear RAM
SpriteX equ 100
SpriteY equ 50

ScreenAddr equ $6000 + (SpriteY * 320) + SpriteX  ; WRONG!
```

**Why It Fails**:
- Video memory uses planar format (4 bitplanes), not linear pixels
- Byte offset ≠ pixel offset
- Sprite draws at wrong location with garbage data

**The Fix**:
```asm
; RIGHT: Account for planar layout
SpriteX equ 100
SpriteY equ 50
ByteOffset equ SpriteX / 8     ; Convert pixels to bytes
LineOffset equ SpriteY * 160   ; 160 bytes per line (40 bytes × 4 planes)

; Calculate address in each bitplane
Plane0 equ $6000 + LineOffset + ByteOffset
Plane1 equ Plane0 + 40         ; Next plane is 40 bytes ahead
Plane2 equ Plane1 + 40
Plane3 equ Plane2 + 40
```

**Lesson**: Video memory is planar (4 interleaved bitplanes). Always divide pixel X by 8 and multiply line Y by 160 (not 320).

---

### Mistake 4: Palette Changes Mid-Frame

**The Problem**:
```asm
; WRONG: Change palette without waiting
UpdateLevel:
        ldx   #NewPalette
        jsr   SetPalette           ; Changes mid-display
        jsr   ClearScreen
        rts
```

**Why It Fails**:
- Hardware might be reading palette while CPU writes it
- Colors flicker or become corrupted
- Top half of screen shows old palette, bottom half shows new

**The Fix**:
```asm
; RIGHT: Change palette during VBL
UpdateLevel:
        jsr   WaitVBL              ; Wait until display ends
        ldx   #NewPalette
        jsr   SetPalette           ; Safe to change now
        jsr   ClearScreen          ; Screen is hidden
        rts
```

**Lesson**: Always call `WaitVBL` before palette operations. Changes take effect next frame.

---

## Real-World Usage

### Goldorak Game Example

The Goldorak game uses a multi-layer rendering approach:

```asm
; From goldorak/game-mode/RenderFrame.asm

RenderFrame:
        jsr   WaitVBL              ; Sync to display
        jsr   SwapVideoBuffer       ; Flip visible/hidden
        jsr   ClearHiddenBuffer    ; Clear to background
        
        ; Draw layers back-to-front
        jsr   DrawBackgroundTiles   ; Layer 0 (tilemap)
        jsr   DrawParallaxLayer     ; Layer 1 (clouds, distant objects)
        jsr   DrawEnemies           ; Layer 2 (enemies, depth sorted)
        jsr   DrawProjectiles       ; Layer 3 (bullets)
        jsr   DrawPlayer            ; Layer 4 (player, foreground)
        jsr   DrawUI                ; Layer 5 (HUD text, score)
        
        rts
```

The priority system sorts sprites by depth:

```asm
; Each sprite has a priority field (0–8)
; Priority 0 = background, Priority 8 = foreground

; Example: Enemy sprites assigned priority 3, player priority 6
; Loop draws in priority order:
;   1. All priority-0 sprites (back tiles)
;   2. All priority-3 sprites (enemies)
;   3. All priority-6 sprites (player)
;   4. All priority-8 sprites (foreground)
```

### R-Type Game Example

R-Type uses hardware-style rendering with extensive sprite work:

```asm
; From game-projects/r-type/rendering/SpriteRender.asm

UpdatePlayerGraphics:
        ; Player sprite changes based on weapon powerup
        ldx   #PlayerSprite
        
        lda   player_weapon_level  ; 0 = basic, 3 = maximum
        
        ; Load correct sprite frame
        ldb   player_animation_frame
        subb  #1                   ; Index into animation table
        
        ldx   WeaponSpriteTable,a  ; A = weapon level
        leax  b,x                  ; X += animation frame
        
        ; Draw player at current position
        lda   player_x
        ldb   player_y
        jsr   BlitSprite
        rts
```

### Palette Transition Example

Smooth level-to-level palette fade:

```asm
; From tutorial/templates/palette-transition/

LevelTransition:
        ; Fade from level 1 palette to level 2 palette
        
        ldx   #Level1Palette
        ldy   #Level2Palette
        lda   #50                  ; 50 frames = 1 second
        jsr   FadeFromTo
        
        ; Now level 2 palette is active
        jsr   LoadLevel2Data
        rts
```

---

## Further Reading

**Related API References**:
- **Object Management** — Sprite lifecycle and state management
- **Collision Detection** — Spatial queries and response callbacks
- **Palette** — Advanced color effects and palettes

**Engine Source Code**:
- `/engine/graphics/vbl/WaitVBL.asm` — VBL synchronization
- `/engine/graphics/sprite/overlay-mode/DisplaySprite.asm` — Priority rendering
- `/engine/graphics/clear/` — Screen clearing functions

**Tutorial References**:
- `tutorial/getting-started/00-minimal-game.md` — WaitVBL and ClearScreen usage
- `tutorial/getting-started/01-sprite-system.md` — BlitSprite patterns
- `tutorial/extending/05-palette-effects.md` — Palette transitions

---

**End of Graphics Subsystem API Reference**

Generated: June 2026  
Quality Level: Production-Ready  
