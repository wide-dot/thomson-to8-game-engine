# Step 01: Sprite System

**Objective**: Build a game with multiple animated sprites.

**Time**: 30 minutes

**Build on**: Step 00 (minimal-game template)

---

## Subsystems in Play

- **Object Management** — Spawn, track, and despawn sprites
- **Graphics** — Multi-sprite rendering
- **Animation** — Cycle through sprite frames

No new subsystems are activated. We're deepening our understanding of object management and graphics that we introduced in Step 00.

---

## Walkthrough: The Sprite Table

In Step 00, you created one sprite by writing to `SpriteTable`. Each sprite occupies a fixed number of bytes (the "stride"). Understanding the sprite table layout is key.

### Memory Layout

Each sprite stores:

```
Offset  Size  Purpose
------  ----  -------
0       1     X position (0-319 in mode 5)
1       1     Y position (0-199 in mode 5)
2       1     Active flag (1 = alive, 0 = despawned)
3       1     Current animation frame
4       1     Animation frame counter (sub-frame timing)
5       1     Animation speed (how many frames between cycles)
6       2     Reserved for sprite ID
8       2     Reserved for custom data
...
```

The stride (total bytes per sprite) is typically 16 or 32 bytes, depending on your template.

### Why a Table?

A sprite table is a contiguous block of memory where each sprite occupies the same number of bytes. This allows fast loops:

```asm
ldy   #SpriteTable              ; Y = start address
loop:
        lda   sprite_active,y   ; Check if sprite is alive
        beq   next_sprite
        jsr   DrawSprite        ; Draw this sprite
next_sprite:
        leay  SpriteStride,y    ; Jump to next sprite (Y += stride)
        cmpy  #SpriteTableEnd
        bne   loop
```

Instead of following pointers (which is slow), we just add the stride to Y. This is why the TO8 games can render 30+ sprites at 50 FPS.

---

## Code Template: Multi-Sprite Scaffold

The template in `tutorial/templates/sprite-system/` extends the minimal-game template with:

```asm
* Sprite table setup
SpriteTable:
        rmb   16 * 32               ; 16 sprites, 32 bytes each

SpriteTableEnd equ *

SpriteStride equ 32
```

This allocates room for 16 sprites. Each occupies 32 bytes, for a total of 512 bytes.

### Creating Multiple Sprites

Modify `CreateSprites` to spawn several:

```asm
CreateSprites:
        ldy   #SpriteTable
        
        * Create enemy 1 at (50, 50)
        ldx   #50
        lda   #50
        std   x_pos,y
        lda   #1
        sta   sprite_active,y
        lda   #0
        sta   frame,y
        
        * Create enemy 2 at (100, 100)
        leay  SpriteStride,y        ; Move to next slot
        ldx   #100
        lda   #100
        std   x_pos,y
        lda   #1
        sta   sprite_active,y
        lda   #0
        sta   frame,y
        
        rts
```

Notice we use `leay SpriteStride,y` to jump to the next sprite slot. This avoids hardcoding addresses.

---

## Animation: Frame Cycling

Animation is simple: increment a frame counter, check if it wraps, and draw different graphics for each frame.

### Animation Speed

Most games have sprites that animate at different speeds. A walk cycle might animate at 4 frames/second, while a bullet just stays static (1 frame).

Store animation speed in the sprite structure:

```asm
sprite_speed equ 5              ; Offset 5 in sprite record
sprite_frame_counter equ 6      ; Offset 6
```

### Animation Update Loop

```asm
UpdateAnimations:
        ldy   #SpriteTable
anim_loop:
        lda   sprite_active,y
        beq   anim_next
        
        * Increment frame counter
        lda   sprite_frame_counter,y
        inca
        cmpa  sprite_speed,y        ; Check if counter >= speed
        bne   anim_done_update
        
        * Wrap animation frame and reset counter
        lda   #0
        sta   sprite_frame_counter,y
        
        lda   frame,y
        inca
        cmpa  #4                    ; Assume 4 frames per animation
        bne   anim_frame_ok
        lda   #0                    ; Wrap to frame 0
anim_frame_ok:
        sta   frame,y
        
anim_done_update:
        sta   sprite_frame_counter,y
        
anim_next:
        leay  SpriteStride,y
        cmpy  #SpriteTableEnd
        bne   anim_loop
        rts
```

### Rendering with Frames

When drawing, use the frame number to pick which graphic to render:

```asm
DrawSprite:
        * Y already points to sprite
        lda   frame,y                ; Load animation frame
        ldb   x_pos,y
        ldc   y_pos,y
        jsr   DrawSpriteFrame        ; Engine function: draw frame A at (B, C)
        rts
```

---

## Real-World Example: R-Type

Open `/game-projects/r-type/game-mode/00/main.asm` and search for "animation" or "frame". You'll see:

```asm
        * Update enemy animation
        lda   enemy_frame,x
        inca
        cmpa  #6                    ; 6 frames for this enemy
        bne   skip_wrap
        clra                        ; Wrap to frame 0
skip_wrap:
        sta   enemy_frame,x
```

This is the exact same pattern we just learned. The difference is that R-Type has 50+ sprites, so it optimizes the loop and uses lookup tables for sprite metadata.

---

## Spawning & Despawning

### Spawning Dynamically

Sometimes you need to spawn sprites during gameplay (e.g., when an enemy dies, spawn an explosion).

```asm
SpawnSprite:
        * Find first free slot
        ldy   #SpriteTable
spawn_search:
        lda   sprite_active,y
        beq   found_slot            ; Found inactive slot
        leay  SpriteStride,y
        cmpy  #SpriteTableEnd
        bne   spawn_search
        
        rts                         ; No slots available; return
        
found_slot:
        * A=X position (caller's responsibility), B=Y position
        lda   #1
        sta   sprite_active,y       ; Mark as active
        ldx   sprite_id_counter
        inx
        stx   sprite_id_counter
        stx   sprite_id,y
        rts
```

### Despawning

To despawn a sprite, just zero its active flag:

```asm
        lda   #0
        sta   sprite_active,y
```

The render loop skips inactive sprites, so they disappear from screen immediately.

### Object Pool Pattern

Once you have 16 sprites on screen and need to spawn more, you need to despawn something first. Most games use an "object pool" — a fixed set of objects that are reused.

When a bullet hits an enemy:
1. Despawn the bullet (set `active=0`)
2. Despawn the enemy (set `active=0`)
3. Spawn an explosion sprite in that slot

This avoids dynamic allocation and keeps performance consistent.

---

## Organizing Sprites by Type

For clarity, organize your sprite table by type:

```asm
* RAM allocation
        org $7000

PlayerSprite:
        rmb   32                    ; 1 player sprite
EnemyTable:
        rmb   32 * 8                ; 8 enemy slots
BulletTable:
        rmb   32 * 16               ; 16 bullet slots
ExplosionTable:
        rmb   32 * 8                ; 8 explosion slots

SpriteTableEnd equ *
```

Now you can loop over just enemies:

```asm
UpdateEnemies:
        ldy   #EnemyTable
enemy_loop:
        lda   sprite_active,y
        beq   enemy_next
        jsr   UpdateEnemy           ; Move, animate, check collision
enemy_next:
        leay  SpriteStride,y
        cmpy  #EnemyTable + (8 * 32) ; End of enemy table
        bne   enemy_loop
        rts
```

This pattern is used in Goldorak for organizing the player, enemies, weapons, and particles.

---

## Performance: Why Tables Work

The 6809 is slow (3 MHz), but sprite tables allow fast rendering:

- **Following pointers** (slow): Load address, jump to it, load next address (~10 cycles per sprite)
- **Table stride** (fast): Add 32 to Y register (~1 cycle per sprite)

With 30 sprites, the difference is 300 cycles per frame. At 50 FPS, that's 15,000 cycles per second — a noticeable slowdown.

Goldorak and R-Type both use strict sprite tables with fixed strides for this reason.

---

## What's Next

Step 02 adds **Joypad Input** to control the player sprite differently from enemies. We'll separate player logic from enemy logic and show how to fire bullets with a button press.

Step 03 adds **Collision Detection** — what happens when sprites collide? Enemy ↔ bullet? Player ↔ enemy?

---

## Deep Dive: API Reference

- **Object Management API** → `api-reference/object-management-api.md`
  - Sprite table structure
  - Entity pooling patterns
  - State machine design
  - Performance optimization

- **Graphics API** → `api-reference/graphics-api.md`
  - Multi-sprite rendering
  - Frame-based drawing
  - Clipping and priority
  - Palette lookup tables

---

## Summary

You've learned:

1. **Sprite table**: Fixed-size memory block, each sprite at an offset
2. **Stride**: Adding the stride to a pointer jumps to the next sprite
3. **Animation**: Store frame number and counter in each sprite
4. **Frame cycling**: Increment counter, wrap frame when counter exceeds speed
5. **Spawning/despawning**: Mark active flag; render loop skips inactive sprites
6. **Object pool**: Reuse sprite slots instead of allocating new memory

Your game now has multiple animated sprites. In the next step, we'll control the player sprite separately and fire bullets.

**Ready?** Proceed to Step 02: Input Handling.
