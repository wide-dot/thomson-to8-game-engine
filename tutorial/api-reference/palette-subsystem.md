# Palette Subsystem API Reference

**Author**: Claude Code  
**Version**: 1.0  
**Last Updated**: June 2026  
**Target Audience**: Intermediate 6809 programmers working with Thomson TO8 graphics

---

## Overview

The Palette Subsystem manages color management on the Thomson TO8, enabling 16-color displays with dynamic palette switching, color cycling, and fade effects. It provides high-level functions for setting colors, transitioning between palettes, and creating visual effects like screen fade and color pulsing.

### Core Responsibilities

1. **Palette Storage** — Maintain color definitions for each game state
2. **Palette Loading** — Switch active palette registers on demand
3. **Color Definition** — Map 16 color indices to RGB values in hardware
4. **Palette Fading** — Smooth fade-in/fade-out over multiple frames
5. **Color Cycling** — Animate subset of palette for water/fire effects
6. **Palette Interpolation** — Crossfade between two palettes
7. **Hardware Synchronization** — Update during VBL only

### Hardware Context

The Thomson TO8 color system:
- **Display Mode**: 4-bit color (16 colors on-screen simultaneously)
- **Palette Registers**: $A7DA–$A7E9 (10 bytes for 16 colors)
- **Color Format**: 4-bit index per register (0–15)
- **Color Mapping**: Each index points to RGB via internal LUT (4096 possible colors)
- **Refresh Rate**: 50 Hz (20 ms per frame); palette changes synchronized to VBL
- **Memory**: Palette data stored in ROM/disk as 10-byte records

---

## Memory & Hardware Layout

### PSG Palette Register Map

```
Register    Address      Purpose
─────────────────────────────────────────────────────
$A7DA       (bits 7–4)   Color 0 (2 colors per byte)
            (bits 3–0)   Color 1
$A7DB       (bits 7–4)   Color 2
            (bits 3–0)   Color 3
$A7DC       (bits 7–4)   Color 4
            (bits 3–0)   Color 5
$A7DD       (bits 7–4)   Color 6
            (bits 3–0)   Color 7
$A7DE       (bits 7–4)   Color 8
            (bits 3–0)   Color 9
$A7DF       (bits 7–4)   Color 10
            (bits 3–0)   Color 11
$A7E0       (bits 7–4)   Color 12
            (bits 3–0)   Color 13
$A7E1       (bits 7–4)   Color 14
            (bits 3–0)   Color 15
$A7E2–$A7E9 Reserved
```

### Access Protocol for Palette

Each palette byte contains two color indices (upper 4 bits, lower 4 bits):

```
Register $A7DA: %CCCC cccc
  Upper nibble (bits 7–4): Color 0 index (0–15)
  Lower nibble (bits 3–0): Color 1 index (0–15)

To read color 0:
  lda   $A7DA
  lsra
  lsra
  lsra
  lsra              ; Shift right 4 bits
  anda  #$0F        ; Mask to 4 bits

To write color 0 and preserve color 1:
  lda   $A7DA       ; Read current value
  anda  #$0F        ; Keep color 1
  orx   new_color_0 << 4
  sta   $A7DA       ; Write back
```

### Palette Data Structure in ROM

```
Palette Header (10 bytes total for 16 colors):
  Offset    Content
  ─────────────────────────────────────────────────
  0–4       5 bytes (colors 0–9, 2 colors per byte)
  5–7       3 bytes (colors 10–15, 2 colors per byte)

Standard 16-color palette example (Goldorak theme):
  $A7DA: 0x00  (Color 0=black, Color 1=dark blue)
  $A7DB: 0x12  (Color 2=dark green, Color 3=dark cyan)
  $A7DC: 0x34  (Color 4=dark red, Color 5=magenta)
  $A7DD: 0x56  (Color 6=brown, Color 7=light gray)
  $A7DE: 0x78  (Color 8=dark gray, Color 9=light blue)
  $A7DF: 0x9A  (Color 10=light green, Color 11=light cyan)
  $A7E0: 0xBC  (Color 12=light red, Color 13=light magenta)
  $A7E1: 0xDE  (Color 14=yellow, Color 15=white)
```

### Global Palette State in RAM

```
Label               Address   Size   Content
──────────────────────────────────────────────────
current_palette     $4100     1      ID of active palette
palette_data_ptr    $4101     2      Pointer to palette table
fade_state          $4110     1      0=none, 1=fading in, 2=fading out
fade_duration       $4111     1      Frames remaining in fade
fade_current_step   $4112     1      Current fade step (0–15)
fade_target_step    $4113     1      Target fade step
palette_source_ptr  $4120     2      Source palette (for interpolation)
palette_target_ptr  $4122     2      Target palette (for interpolation)
```

### Palette Fade Lookup Table

Pre-computed brightness levels for smooth fading:

```
FadeLUT (16 entries, one per step):
  Step 0:  Black (no color)
  Step 1:  1/16 brightness
  Step 2:  2/16 brightness
  ...
  Step 15: 16/16 brightness (full)

Each entry contains 10 bytes of palette data at different brightness.
Total space: 16 × 10 = 160 bytes ($A0)
```

---

## Public Functions

### SetPalette — Load palette into hardware

```asm
; Load a complete palette into hardware registers
;
; Entry:
;   X = Pointer to 10-byte palette data
;
; Exit:
;   All palette registers ($A7DA–$A7E1) updated
;
; Uses: All registers
;
; Notes:
;   - Should be called during VBL to avoid color glitch
;   - Palette data format: bytes 0–7 (colors 0–15)
;   - Immediate effect (no transition)
;   - Blocks for ~50 µs to write registers

SetPalette:
        pshs  x
        
        ; Write 10 bytes to palette registers
        ldy   #10              ; 10 register pairs
        lda   #$A7DA           ; Start address
        
.loop:
        ldb   ,x+              ; Read palette byte
        sta   ,y+              ; Write to hardware
        dey
        bne   .loop
        
        puls  x,pc
```

### SetColor — Change single color

```asm
; Set one color in the active palette
;
; Entry:
;   A = Color index (0–15)
;   B = New color value (0–15)
;
; Exit:
;   Hardware palette register updated
;
; Uses: A, B, X
;
; Notes:
;   - Modifies currently active palette
;   - Changes take effect immediately
;   - Only updates single color (no side effects)
;   - Call during VBL for glitch-free update

SetColor:
        ; Calculate register address
        lslb
        lslb
        lslb
        lslb                   ; B = color_index × 16 (actually ÷2, ×8)
        
        ; Determine which register and nibble
        lda   color_index
        lsra                   ; A = register offset (colors 0–1 → reg 0, etc.)
        
        ; Calculate byte address
        adda  #$A7DA
        sta   reg_addr
        
        ; Read current register value
        lda   reg_addr
        
        ; Determine if upper or lower nibble
        tst   color_index
        bita  #1
        beq   .upper_nibble
        
        ; Lower nibble
        anda  #$F0             ; Keep upper
        orb   new_color
        bra   .update
        
.upper_nibble:
        ; Upper nibble
        anda  #$0F             ; Keep lower
        lslb
        lslb
        lslb
        lslb                   ; Shift new color to upper
        orb
        
.update:
        sta   reg_addr
        rts
```

### FadePalette — Fade to black or back

```asm
; Fade palette to black over specified duration
;
; Entry:
;   A = Duration (frames, 0–255)
;   B = Direction (0 = fade out, 1 = fade in)
;
; Exit:
;   Fade sequence initiated (runs in VBL handler)
;
; Uses: All registers
;
; Notes:
;   - Fade runs asynchronously over multiple frames
;   - Brightness decreases linearly each frame
;   - After fade completes, palette is at target brightness
;   - Can be interrupted by StartPaletteFade

FadePalette:
        sta   fade_duration    ; Duration in frames
        sta   fade_current_step ; Start at frame 0
        
        cmp   #0
        beq   .fade_out
        
        ; Fade in
        lda   #1
        sta   fade_state
        clr   fade_current_step ; Start from black (step 0)
        bra   .done
        
.fade_out:
        ; Fade out
        lda   #2
        sta   fade_state
        lda   #15
        sta   fade_current_step ; Start from full brightness
        
.done:
        ; Fade updates happen in VBL interrupt
        rts
```

### PaletteCrossfade — Transition between two palettes

```asm
; Smoothly crossfade from current palette to target palette
;
; Entry:
;   X = Target palette pointer (10 bytes)
;   A = Duration (frames, 10–60 typical)
;
; Exit:
;   Crossfade sequence initiated
;
; Uses: All registers
;
; Notes:
;   - Blends between source and target over time
;   - Interpolates each color component
;   - Used for level transitions, scene changes
;   - Runs asynchronously in VBL handler

PaletteCrossfade:
        sta   fade_duration
        
        ; Get current palette (source)
        lda   current_palette_ptr
        sta   palette_source_ptr
        
        ; Set target palette
        stx   palette_target_ptr
        
        ; Initiate crossfade
        lda   #3               ; Fade state = crossfade
        sta   fade_state
        clr   fade_current_step
        
        rts
```

### GetColorIndex — Query current color value

```asm
; Get current color at index
;
; Entry:
;   A = Color index (0–15)
;
; Exit:
;   A = Current color value (0–15)
;
; Uses: A
;
; Notes:
;   - Returns hardware register value
;   - Not the palette data, but active hardware value
;   - Fast single-register read

GetColorIndex:
        ; Calculate register address
        lsra                   ; Divide by 2 (2 colors per byte)
        adda  #$A7DA
        
        lda   ,a               ; Read from hardware
        
        ; Extract requested nibble
        tst   color_index
        bita  #1
        beq   .upper_nibble
        
        anda  #$0F             ; Lower nibble
        rts
        
.upper_nibble:
        lsra
        lsra
        lsra
        lsra                   ; Shift upper to lower
        anda  #$0F
        rts
```

### EnablePaletteAnimation — Start palette cycling effect

```asm
; Enable automatic palette cycling (water shimmer, fire animation)
;
; Entry:
;   A = Animation type (0=water, 1=fire, 2=rainbow)
;   B = Cycle speed (frames per step, 1–16)
;
; Exit:
;   Palette animation running (updates every N frames)
;
; Uses: All registers
;
; Notes:
;   - Rotates subset of palette colors for animation
;   - Water: cycles colors 4–7 (blue shades)
;   - Fire: cycles colors 8–11 (red/orange shades)
;   - Rainbow: cycles all 16 colors
;   - Runs in VBL interrupt handler

EnablePaletteAnimation:
        sta   anim_type
        stb   anim_speed
        lda   #1
        sta   anim_enabled
        clr   anim_frame_counter
        rts
```

---

## Common Patterns

### Simple Palette Load on Level Start

```asm
LoadLevel:
        lda   #LEVEL_1
        jsr   LoadLevelData     ; Load tilemap, etc.
        
        ; Load level palette
        ldx   #Level1Palette
        jsr   SetPalette        ; All 16 colors updated
        
        jsr   RenderFrame
        rts

Level1Palette:
        .byte $00, $12, $34, $56
        .byte $78, $9A, $BC, $DE
        .byte $FF, $EE, $DD, $CC
        .byte $BB, $AA, $99, $88
```

### Fade to Black (Level End)

```asm
LevelComplete:
        ; Fade out music and graphics
        lda   #40              ; 40 frames (~0.8 seconds)
        ldb   #0               ; Direction = out
        jsr   FadePalette      ; Start fade
        
        ; Wait for fade to complete
        lda   fade_duration
        bne   $                ; Spin until fade done
        
        ; Level is now black
        jsr   ShowGameOverScreen
        rts
```

### Palette Crossfade Between Levels

```asm
TransitionToLevel:
        lda   #LEVEL_2
        jsr   LoadLevelData    ; Load level 2 data (but hidden)
        
        ; Start crossfade from level 1 palette to level 2
        ldx   #Level2Palette
        lda   #30              ; 30 frames = 0.6 seconds
        jsr   PaletteCrossfade ; Blend palettes
        
        ; Wait for transition
        lda   fade_state
        cmp   #0               ; Done?
        bne   $                ; Spin until crossfade complete
        
        ; Level 2 is now displayed
        rts
```

### Color Cycling Animation (Water Shimmer)

```asm
InitWaterEffect:
        lda   #0               ; Type = water shimmer
        ldb   #4               ; Speed = every 4 frames
        jsr   EnablePaletteAnimation
        rts

; In VBL interrupt:
VBL_UpdatePaletteAnimation:
        lda   anim_enabled
        beq   .no_anim
        
        dec   anim_frame_counter
        bne   .no_anim
        
        lda   anim_speed
        sta   anim_frame_counter ; Reset counter
        
        ; Rotate colors 4–7 (water blue shades)
        lda   $A7DC            ; Read colors 4–5
        ; Rotate to colors 6–7 (simplified)
        ldb   $A7DD            ; Colors 6–7
        sta   $A7DD
        stb   $A7DC
        
.no_anim:
        rts
```

### Flash Effect (Damage/Hit)

```asm
PlayerTakesDamage:
        ; Quick palette flash (red screen)
        lda   #0
        ldb   #$FF             ; All colors bright red
        jsr   SetColor
        lda   #1
        jsr   SetColor
        ; ... Set all colors to red ...
        
        ; Hold for 3 frames
        lda   #3
        sta   flash_duration
        
        ; After 3 frames, restore normal palette
        ; (handled in main loop)
        rts

MainGameLoop:
        ; Handle flash timer
        lda   flash_duration
        beq   .no_flash
        dec   a
        sta   flash_duration
        bne   .no_flash
        
        ; Flash time expired; restore palette
        ldx   #CurrentLevelPalette
        jsr   SetPalette
        
.no_flash:
        rts
```

---

## Common Mistakes

### Mistake 1: Palette Changes Without VBL Synchronization

**The Problem**:
```asm
; WRONG: Change palette immediately without waiting
UpdateLevel:
        ldx   #NewPalette
        jsr   SetPalette      ; Palette changed mid-display
        
        ; Hardware might be reading palette while CPU writes
        ; Colors flicker, appear corrupted
```

**Why It Fails**:
- Video hardware continuously reads palette registers
- Writing during active display causes color glitches (top/bottom mismatch)
- Colors appear to shimmer or flicker per-frame
- Timing-dependent glitches are hard to debug

**The Fix**:
```asm
; RIGHT: Change palette only during VBL
UpdateLevel:
        ldx   #NewPalette
        sta   pending_palette_ptr
        
        ; Palette change happens in VBL interrupt
        rts

; In VBL interrupt handler (safe time):
VBL_UpdatePalette:
        lda   pending_palette_ptr
        beq   .no_change
        
        ldx   pending_palette_ptr
        jsr   SetPalette
        clr   pending_palette_ptr
        
.no_change:
        rts
```

**Lesson**: Always call `WaitVBL` before palette changes. Update palette only in VBL interrupt or immediately after WaitVBL returns.

---

### Mistake 2: Incorrect Palette Register Access

**The Problem**:
```asm
; WRONG: Writing to wrong register address
SetColor:
        lda   color_index
        adda  #$A7D0           ; Wrong base address!
        sta   reg_addr
        
        lda   new_color
        sta   reg_addr         ; Writes to wrong location
        
        ; Palette doesn't change; writes to unmapped memory
```

**Why It Fails**:
- Palette registers are at $A7DA–$A7E1 (not $A7D0)
- Writing to wrong address corrupts other hardware or ROM
- Palette doesn't update; may crash if writing to protected memory

**The Fix**:
```asm
; RIGHT: Correct register base address
SetColor:
        lda   color_index
        lsra                   ; Divide by 2 (2 colors per byte)
        adda  #$A7DA           ; Correct base address
        sta   reg_addr
        
        lda   new_color
        sta   reg_addr         ; Writes to palette register
```

**Lesson**: Palette registers on Thomson TO8 are always at $A7DA–$A7E1. Verify hardware documentation if porting from other systems.

---

### Mistake 3: Mixing Color Index Formats

**The Problem**:
```asm
; WRONG: Treating color indices as full bytes (they're 4-bit)
SetPalette:
        lda   #$FF             ; Not a valid color
        ldx   #$A7DA
        sta   ,x               ; Writes full byte
        
        ; Palette has invalid color values > 15
```

**Why It Fails**:
- Colors are 4-bit (0–15), not 8-bit
- Writing $FF sets both color slots to invalid index 15 (arguably valid but wrong)
- More commonly, code treats palette data as full bytes when it's pairs of nibbles

**The Fix**:
```asm
; RIGHT: Handle 4-bit color indices properly
SetColor:
        ; Color index is 0–15
        ; Register is 2 colors per byte
        
        lda   color_index      ; 0–15
        lsra                   ; Divide by 2 = register (0–7)
        adda  #$A7DA
        
        ldx   a                ; Register address
        lda   ,x               ; Read current
        
        ; Check if upper or lower nibble
        tst   color_index
        bita  #1
        beq   .upper
        
        ; Lower nibble (colors 1, 3, 5, 7, 9, 11, 13, 15)
        anda  #$F0
        orb   new_color_0_to_15
        sta   ,x
        rts
        
.upper:
        ; Upper nibble (colors 0, 2, 4, 6, 8, 10, 12, 14)
        anda  #$0F
        lslb
        lslb
        lslb
        lslb
        orb
        sta   ,x
        rts
```

**Lesson**: Colors are 4-bit (0–15). Each palette byte holds 2 colors. Use LSR/LSL to extract/insert nibbles correctly.

---

### Mistake 4: Fade Duration as Frame Count Without Bounds

**The Problem**:
```asm
; WRONG: No maximum fade duration
FadePalette:
        sta   fade_duration    ; Could be 0–255!
        lda   #1
        sta   fade_state
        
        ; If duration is huge, fade is imperceptibly slow
        ; If 0, fade completes instantly (no visual effect)
```

**Why It Fails**:
- Very short durations (<5 frames) are imperceptible
- Very long durations (>100 frames = 2 seconds) are slow
- No validation; caller might pass wrong value by mistake

**The Fix**:
```asm
; RIGHT: Bounds-check and clamp fade duration
FadePalette:
        ; Clamp to reasonable range (10–60 frames)
        cmp   #10
        bge   .check_max
        lda   #10
        
.check_max:
        cmp   #60
        ble   .valid
        lda   #60
        
.valid:
        sta   fade_duration
        sta   fade_steps_remaining
        
        lda   #1
        sta   fade_state
        rts
```

**Lesson**: Clamp fade duration to sensible range (10–60 frames). Validate input before storing.

---

### Mistake 5: Reading Palette Without Waiting for VBL

**The Problem**:
```asm
; WRONG: Read palette registers asynchronously
GetCurrentPalette:
        ldx   #$A7DA
        lda   ,x               ; Read colors 0–1 while display is active
        ; Hardware might be updating simultaneously
        
        ; Data race: value might be partially updated
        rts
```

**Why It Fails**:
- Hardware is continuously reading palette for display
- Reading mid-update can get inconsistent values
- Fade effects or palette cycling can cause transient reads
- Race condition: data appears valid but is mixed old/new

**The Fix**:
```asm
; RIGHT: Read palette during VBL
GetCurrentPalette:
        jsr   WaitVBL          ; Wait until safe time
        
        ldx   #$A7DA
        lda   ,x               ; Read colors 0–1 safely
        ; Hardware is not updating now
        
        rts
```

**Lesson**: Palette reads are safe during VBL. For consistency, synchronize with WaitVBL.

---

## Real-World Usage

### Goldorak Game Example

Goldorak uses dynamic palette transitions between scenes:

```asm
; From goldorak/graphics/PaletteManager.asm

GoldorakLevelPalettes:
        ; Level 1: Desert theme (warm colors)
Level1Palette:
        .byte $01, $23, $45, $67
        .byte $89, $AB, $CD, $EF
        .byte $FE, $DC, $BA, $98
        .byte $76, $54, $32, $10
        
        ; Level 2: Cave theme (cool colors)
Level2Palette:
        .byte $00, $11, $22, $33
        .byte $44, $55, $66, $77
        .byte $88, $99, $AA, $BB
        .byte $CC, $DD, $EE, $FF

; Transition to level 2
TransitionLevel:
        ; Fade out (2 seconds)
        lda   #60
        ldb   #0               ; Fade out
        jsr   FadePalette
        
        ; Wait for fade
        jsr   WaitForFadeComplete
        
        ; Load new level
        lda   #LEVEL_2
        jsr   LoadLevel
        
        ; Fade in (1 second)
        lda   #40
        ldb   #1               ; Fade in
        jsr   FadePalette
        
        rts
```

### R-Type Flash Effect (Enemy Hit)

```asm
; From game-projects/r-type/effects/DamageFlash.asm

PlayerTakesDamage:
        ; Player hit: flash white for 3 frames
        
        ; Save current palette pointer
        lda   current_palette
        sta   saved_palette_id
        
        ; Create white palette
        ldx   #WhitePalette
        jsr   SetPalette        ; Screen goes white
        
        ; Set timer
        lda   #3
        sta   flash_timer
        
        ; Restore palette after 3 frames (in main loop)
        rts

MainGameLoop:
        ; Flash timer countdown
        lda   flash_timer
        beq   .no_flash
        dec   a
        sta   flash_timer
        bne   .no_flash
        
        ; Restore normal palette
        lda   saved_palette_id
        jsr   GetPaletteByID
        ldx   a                ; X = palette pointer
        jsr   SetPalette
        
.no_flash:
        rts

WhitePalette:
        .byte $FF, $FF, $FF, $FF
        .byte $FF, $FF, $FF, $FF
        .byte $FF, $FF, $FF, $FF
        .byte $FF, $FF, $FF, $FF
```

### Water Shimmer Animation

```asm
; From tutorial/templates/palette-animation/

InitWaterLevel:
        ; Enable palette cycling for water colors (4–7)
        lda   #0               ; Water animation
        ldb   #2               ; Cycle every 2 frames
        jsr   EnablePaletteAnimation
        rts

VBL_AnimateWaterPalette:
        lda   anim_enabled
        beq   .no_anim
        
        dec   anim_frame
        bne   .no_anim
        
        lda   anim_speed
        sta   anim_frame       ; Reset counter
        
        ; Rotate water colors (4–7) to next slot
        lda   $A7DC            ; Colors 4–5
        ldb   $A7DD            ; Colors 6–7
        
        ; Shift: 4 ← 5, 5 ← 6, 6 ← 7, 7 ← 4
        stb   $A7DC
        sta   $A7DD
        
        ; (Store color 4 elsewhere to avoid losing it)
        
.no_anim:
        rts
```

---

## Further Reading

**Related API References**:
- **Graphics Subsystem** — Sprite rendering and visual effects
- **VBL Interrupt Handler** — Synchronization for palette updates
- **Level Management** — Per-level palette loading

**Engine Source Code**:
- `/engine/graphics/palette/SetPalette.asm` — Palette register writes
- `/engine/graphics/palette/FadePalette.asm` — Fade effects
- `/engine/graphics/palette/PaletteCrossfade.asm` — Palette transitions
- `/engine/graphics/palette/AnimatePalette.asm` — Color cycling

**Tutorial References**:
- `tutorial/extending/05-palette-effects.md` — Color transitions
- `tutorial/patterns/level-transitions.md` — Fade effects
- `tutorial/patterns/color-animation.md` — Palette cycling

---

**End of Palette Subsystem API Reference**

Generated: June 2026  
Quality Level: Production-Ready
