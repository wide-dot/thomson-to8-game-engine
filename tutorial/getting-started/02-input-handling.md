# Step 02: Input Handling

**Objective**: Accept joypad buttons and directional input; spawn bullets when fire button is pressed.

**Time**: 20 minutes

**Build on**: Step 01 (sprite-system template)

---

## Subsystems in Play

- **Joypad Input** — Read all button states
- **Object Management** — Spawn bullets dynamically
- **Collision Detection** — Prevent off-screen bullets

No new systems are activated. We're expanding the joypad reading from Step 00 to include buttons (not just directions) and adding dynamic spawning from Step 01.

---

## Walkthrough: Joypad Byte Layout

The Thomson TO8 uses a 6821 PIA (Programmable Interface Adapter) that splits joypad input across two ports. Each port returns a byte where specific bits represent inputs:

```
Port A (Directional Pad) at $E7CC
Bit 3: North (1 = pressed)
Bit 2: South (1 = pressed)
Bit 1: East (1 = pressed)
Bit 0: West (1 = pressed)

Port B (Action Buttons) at $E7CD
Bit 6: Fire/Button A (1 = pressed)
Bit 2: Button B (1 = pressed)
```

Note: Unlike modern controllers, **1 = pressed** (active high). When a button is not pressed, the bit is 0.

### Reading Individual Buttons

Use `bita` (bit test accumulator) to check a specific button without destroying the byte:

```asm
        lda   joypad_state

        * Check fire button (bit 6 of Port B)
        bita  #$80                  ; 0x80 = 1000 0000 in binary
        beq   not_firing            ; Zero flag set if bit was 0
        jsr   FireBullet            ; Fire button is pressed
not_firing:

        * Check A button (bit 5)
        bita  #$20                  ; 0x20 = 0010 0000
        beq   not_a_button
        jsr   SpecialAttack
not_a_button:
        
        rts
```

### Debouncing: Fire Once Per Press

The main game loop runs every 20 milliseconds (50 FPS). If you fire a bullet every frame the fire button is held, you'll fire 50 bullets in one second.

Most games want one bullet per button press. Use a "fire key released" state:

```asm
        * In your sprite/game state
fire_key_was_pressed equ 7         ; Offset 7: was fire pressed last frame?

        * In update loop
UpdatePlayer:
        ldx   #$E7CD                ; Port B (buttons)
        lda   ,x
        bita  #$40                  ; Fire button (bit 6) pressed now?
        beq   fire_released
        
        * Fire button is pressed
        lda   fire_key_was_pressed,y
        bne   already_fired         ; Already fired this press; skip
        lda   #1
        sta   fire_key_was_pressed,y
        jsr   FireBullet            ; Fire once
        bra   fire_done
        
already_fired:
        bra   fire_done
        
fire_released:
        * Fire button released
        lda   #0
        sta   fire_key_was_pressed,y ; Reset for next press
        
fire_done:
        rts
```

This pattern:
1. Stores whether fire was pressed last frame
2. Only fires when transitioning from unpressed → pressed
3. Prevents firing multiple bullets per press

### Port Addressing

The TO8 uses the 6821 PIA for joypad input:

```
Port A ($E7CC):  Directional input (North/South/East/West)
Port B ($E7CD):  Button input (Fire/Button A on bit 6, Button B on bit 2)
```

For single-player games, read port A:

```asm
ReadJoypad:
        * Read directional input (Port A)
        ldx   #$E7CC
        lda   ,x
        sta   joypad_state_dir
        
        * Read button input (Port B)
        ldx   #$E7CD
        lda   ,x
        sta   joypad_state_btn
        rts
```

For two-player games, read both ports:

```asm
ReadJoypads:
        ldx   #$A7E0
        lda   ,x
        sta   joypad_state_p1
        
        ldx   #$A7E1
        lda   ,x
        sta   joypad_state_p2
        rts
```

---

## Firing Bullets: Dynamic Spawning

When the fire button is pressed, spawn a bullet at the player's position.

### Bullet Slot Management

Allocate a bullet table (from Step 01):

```asm
BulletTable:
        rmb   32 * 16               ; 16 bullets max
BulletTableEnd equ *
```

### Spawn Bullet Routine

```asm
FireBullet:
        * Y = player sprite address (from caller)
        * Find first free bullet slot
        ldx   #BulletTable
bullet_search:
        lda   sprite_active,x
        beq   bullet_found
        leax  SpriteStride,x
        cmpx  #BulletTableEnd
        bne   bullet_search
        rts                         ; No free slots; bullet cannot fire
        
bullet_found:
        * Spawn bullet at player position
        lda   x_pos,y               ; Get player X
        sta   x_pos,x               ; Store in bullet
        lda   y_pos,y
        suba  #8                    ; Offset above player
        sta   y_pos,x
        
        lda   #1
        sta   sprite_active,x       ; Mark bullet as active
        
        lda   #2                    ; Bullet velocity = 2 pixels/frame
        sta   x_vel,x
        lda   #0
        sta   y_vel,x
        
        rts
```

### Update Bullets

In the main loop, move bullets toward the right:

```asm
UpdateBullets:
        ldx   #BulletTable
bullet_update_loop:
        lda   sprite_active,x
        beq   bullet_update_next
        
        * Move bullet
        lda   x_pos,x
        adda  x_vel,x
        sta   x_pos,x
        
        * Check off-screen
        cmpa  #319
        bls   bullet_update_next     ; Still on screen
        lda   #0
        sta   sprite_active,x       ; Despawn
        
bullet_update_next:
        leax  SpriteStride,x
        cmpx  #BulletTableEnd
        bne   bullet_update_loop
        rts
```

Notice: We're removing off-screen bullets automatically. This prevents unused bullets from piling up in memory.

---

## Real-World Example: R-Type

Open `/game-projects/r-type/game-mode/00/main.asm` and search for "fire" or "bullet". You'll find patterns like:

```asm
        * Check fire button
        tst   fire_pressed
        beq   skip_fire
        
        * Find bullet slot and fire
        jsr   AllocateBullet
        bne   skip_fire
        
        lda   player_x
        sta   bullet_x,x
        
        lda   #$FF                  ; Bullet velocity
        sta   bullet_vel_x,x
        
skip_fire:
```

R-Type manages multiple weapon types (standard shots, powered-up shots, special attacks), but the core pattern is the same: check button, find slot, spawn object.

---

## Organizing Input by Role

For clarity, separate player input from enemy AI:

```asm
UpdatePlayer:
        * Read joypad
        jsr   ReadJoypad
        
        * Move based on input
        lda   joypad_state
        bita  #$04                  ; Right?
        beq   p_not_right
        lda   x_pos,y
        adda  #2
        sta   x_pos,y
p_not_right:
        
        * Check fire
        bita  #$80
        beq   p_not_fire
        jsr   FireBullet
p_not_fire:
        rts

UpdateEnemies:
        * Simple AI: move toward player
        ldx   #EnemyTable
enemy_loop:
        lda   sprite_active,x
        beq   enemy_next
        
        * AI: move left
        lda   x_pos,x
        suba  #1
        sta   x_pos,x
        
        * Despawn if off-screen
        cmpa  #0
        bges  enemy_next
        lda   #0
        sta   sprite_active,x
        
enemy_next:
        leax  SpriteStride,x
        cmpx  #EnemyTableEnd
        bne   enemy_loop
        rts
```

This separates concerns: player input and physics are distinct from enemy AI.

---

## Multi-Player Input

For two-player games, read both ports:

```asm
UpdatePlayers:
        * Player 1 (port A)
        ldy   #PlayerTable
        lda   joypad_state_p1
        jsr   UpdatePlayerWithInput
        
        * Player 2 (port B)
        ldy   #PlayerTable + 32
        lda   joypad_state_p2
        jsr   UpdatePlayerWithInput
        rts

UpdatePlayerWithInput:
        * A = joypad state, Y = player sprite address
        bita  #$04                  ; Right?
        beq   not_right
        lda   x_pos,y
        adda  #2
        sta   x_pos,y
not_right:
        rts
```

---

## Button Combinations

Some games check multiple buttons simultaneously (e.g., Up+Fire = special attack):

```asm
        lda   joypad_state
        anda  #$90                  ; Mask: up (0x10) + fire (0x80)
        cmpa  #$90                  ; Both bits set?
        bne   not_special
        jsr   SpecialAttack
not_special:
```

---

## What's Next

Step 03 adds **Collision Detection**. We have bullets now, but they pass through enemies. You'll learn:

- How to detect when a bullet overlaps an enemy
- How to despawn both and spawn an explosion
- How to track score and game state

---

## Deep Dive: API Reference

- **Joypad API** → `api-reference/joypad-api.md`
  - Port addresses and bit layouts
  - Debouncing techniques
  - Multi-player input handling
  - Hardware interrupts for polling

- **Object Management API** → `api-reference/object-management-api.md`
  - Dynamic object spawning
  - Object pool allocation
  - Despawn strategies

---

## Summary

You've learned:

1. **Joypad byte**: Each bit is a button or direction
2. **Bit testing**: Use `bita` and `beq` to check individual buttons
3. **Debouncing**: Track "was pressed last frame" to fire once per press
4. **Dynamic spawning**: Find a free slot, initialize object, set active
5. **Off-screen cleanup**: Despawn bullets that leave the screen
6. **Multi-player**: Read both ports for two-player support

Your game now responds to all joypad inputs and fires bullets. You can move the player with the directional pad and fire with the button.

In Step 03, we'll detect collisions between bullets and enemies.

**Ready?** Proceed to Step 03: Collision Detection.
