# Step 03: Collision Detection

**Objective**: Detect collisions between bullets and enemies; despawn both and update game state.

**Time**: 25 minutes

**Build on**: Step 02 (input-handling template)

---

## Subsystems in Play

- **Collision Detection** — Check bounding box overlaps
- **Object Management** — Despawn on collision, manage sprite pool
- **Game State** — Track score and game progress

This is the final step of the getting-started tutorial. When you complete it, you have a complete game: player movement, bullet firing, enemy behavior, collision response, and scoring.

---

## Walkthrough: Bounding Box Collision

Collision detection on the TO8 is usually done with **bounding boxes** — axis-aligned rectangles around sprites.

### The Simple Case: Point-in-Box

A bullet is typically small (1-4 pixels). An enemy is larger (16x16 or 32x32 pixels). To check if a bullet hits:

```
Bullet at (bx, by)
Enemy at (ex, ey) with size (ew, eh)

Collision if:
  bx >= ex && bx < (ex + ew) &&
  by >= ey && by < (ey + eh)
```

### Box-in-Box: Two Rectangles

For larger objects (player vs. enemy):

```
Player box: (px, py) size (pw, ph)
Enemy box:  (ex, ey) size (ew, eh)

No collision if:
  px + pw <= ex ||        (player right of enemy)
  ex + ew <= px ||        (enemy right of player)
  py + ph <= ey ||        (player below enemy)
  ey + eh <= py           (enemy below player)

Collision if NOT (any of above)
```

This is the "separating axis theorem" for axis-aligned boxes: if there's a gap on any side, there's no collision.

### Storing Collision Bounds

Add collision bounds to each sprite:

```asm
* Sprite structure offsets
x_pos       equ 0
y_pos       equ 1
sprite_active equ 2
frame       equ 3

* Collision bounds
col_x_offset equ 8       ; Offset from sprite center
col_y_offset equ 9
col_width    equ 10
col_height   equ 11

* Example: 32x32 sprite with 16x16 collision box
*   (centered, 8 pixels from edge)
```

### Collision Check Routine

```asm
CheckCollisionBoxes:
        * X = bullet address, Y = enemy address
        * Returns with Z flag set if collision
        
        lda   x_pos,x
        adda  col_x_offset,x        ; Bullet left edge
        sta   <bullet_left
        
        lda   x_pos,x
        adda  col_x_offset,x
        adda  col_width,x
        sta   <bullet_right         ; Bullet right edge
        
        lda   y_pos,x
        adda  col_y_offset,x        ; Bullet top edge
        sta   <bullet_top
        
        * Same for enemy
        lda   x_pos,y
        adda  col_x_offset,y
        sta   <enemy_left
        
        lda   x_pos,y
        adda  col_x_offset,y
        adda  col_width,y
        sta   <enemy_right
        
        * Separating axis test
        lda   <bullet_right
        cmpa  <enemy_left
        bls   no_collision          ; Gap on left side
        
        lda   <enemy_right
        cmpa  <bullet_left
        bls   no_collision          ; Gap on right side
        
        * Y axis (similar logic)
        lda   <bullet_bottom
        cmpa  <enemy_top
        bls   no_collision
        
        lda   <enemy_bottom
        cmpa  <bullet_top
        bls   no_collision
        
        * Collision detected! Return with A=1
        lda   #1
        rts
        
no_collision:
        * No collision. Return with A=0 (will set Z flag)
        lda   #0
        rts
```

### Collision Query Routine

```asm
CheckBulletEnemyCollisions:
        ldx   #BulletTable
bullet_collision_loop:
        lda   sprite_active,x
        beq   bullet_col_next
        
        * Check this bullet against all enemies
        ldy   #EnemyTable
enemy_collision_loop:
        lda   sprite_active,y
        beq   enemy_col_next
        
        jsr   CheckCollisionBoxes
        cmpa  #0                    ; Check return value in A
        beq   no_hit                ; A=0 means no collision
        
        * Collision! Handle it
        jsr   OnBulletHitEnemy
        bra   bullet_col_next       ; Bullet despawned; skip remaining enemies for this bullet
        
no_hit:
        leay  SpriteStride,y
        cmpy  #EnemyTableEnd
        bne   enemy_collision_loop
        
bullet_col_next:
        leax  SpriteStride,x
        cmpx  #BulletTableEnd
        bne   bullet_collision_loop
        rts
```

Notice: We check every bullet against every enemy. With 16 bullets and 8 enemies, that's 128 checks per frame. At 50 FPS, that's 6,400 checks/second — very manageable for the 6809.

---

## Handling Collisions: Response

When a bullet hits an enemy:

```asm
OnBulletHitEnemy:
        * X = bullet, Y = enemy
        
        * Despawn bullet
        lda   #0
        sta   sprite_active,x
        
        * Despawn enemy
        lda   #0
        sta   sprite_active,y
        
        * Spawn explosion (optional)
        lda   x_pos,y
        stx   <temp_x               ; Save registers
        sty   <temp_y
        ldx   <temp_x
        jsr   SpawnExplosion        ; Allocate and spawn
        ldx   <temp_x
        ldy   <temp_y
        
        * Update score
        lda   score
        adda  #10
        sta   score
        
        rts
```

### Player vs. Enemy Collision

Player takes damage instead of despawning:

```asm
OnPlayerHitEnemy:
        * Y = player, X = enemy
        
        * Decrement player health
        lda   player_health,y
        suba  #1
        sta   player_health,y
        beq   game_over             ; Health = 0; end game
        
        * Despawn enemy
        lda   #0
        sta   sprite_active,x
        
        * Spawn explosion
        lda   x_pos,x
        jsr   SpawnExplosion
        
        rts

game_over:
        lda   #1
        sta   game_state            ; Set state to "game over"
        rts
```

---

## Game State Management

Track game progress with a simple state variable:

```asm
game_state equ 0                ; 0 = playing, 1 = game over, 2 = won

* In main loop
MainLoop:
        jsr   ReadJoypad
        
        lda   game_state
        beq   state_playing
        cmpa  #1
        beq   state_game_over
        bra   state_won
        
state_playing:
        jsr   UpdatePlayer
        jsr   UpdateEnemies
        jsr   UpdateBullets
        jsr   CheckBulletEnemyCollisions
        jsr   CheckPlayerEnemyCollisions
        jsr   RenderFrame
        bra   main_loop_end
        
state_game_over:
        jsr   RenderGameOverScreen
        * Check if player presses start to restart
        lda   joypad_state
        bita  #$10                  ; Start button?
        beq   main_loop_end
        jsr   ResetGame
        bra   main_loop_end
        
state_won:
        jsr   RenderWinScreen
        bra   main_loop_end
        
main_loop_end:
        jsr   WaitVBL
        bra   MainLoop
```

---

## Real-World Example: Goldorak

Open `/game-projects/goldorak/game-mode/gamescreen/main.asm` and search for "collision" or "hit":

You'll find patterns like:

```asm
        * Check if goldorak hit an enemy
        lda   player_collision_box_x
        cmpa  enemy_x,x
        bls   no_hit
        
        lda   enemy_x,x
        adda  enemy_width,x
        cmpa  player_x
        bls   no_hit
        
        * Collision detected
        jsr   DamagePlayer
        
no_hit:
```

Goldorak checks collisions for:
1. Bullets ↔ Enemies
2. Player ↔ Enemies
3. Player ↔ Collectibles

Each has its own response handler.

---

## Performance: Broad-Phase Filtering

With many sprites, checking every pair is slow. Use "broad-phase" filtering to skip obviously non-colliding objects:

```asm
        * Quick check: are sprites close enough?
        lda   x_pos,x
        suba  x_pos,y
        bra   abs_check
        
abs_check:
        * If difference > max distance, no collision possible
        cmpa  #64                   ; 64 pixels apart
        bhi   skip_collision
        
        * Only then do full bounding box check
        jsr   CheckCollisionBoxes
        beq   no_collision
        
        * Full collision handling
        jsr   OnBulletHitEnemy
```

This reduces checks from O(n²) to O(n) in practice.

---

## Spatial Partitioning: Advanced

For games with 50+ sprites, even broad-phase filtering isn't enough. Use **spatial partitioning**: divide the screen into a grid and only check collisions within the same cell.

```asm
* Screen is divided into 4x4 grid (160x160 pixels each)
* Each sprite stores which grid cell it's in

GetGridCell:
        * A = X position, returns cell (0-15)
        lsra                        ; Divide by 160
        lsra
        lsra
        lsra
        lsra
        lsra
        lsra                        ; A = X / 160
        rts
```

Then only check collisions within the same cell. This reduces checks to O(n).

Goldorak uses a simpler approach: it only checks collisions for sprites within a certain distance of the player.

---

## Pixel-Perfect Collision

For complex shapes (non-rectangular sprites), use **pixel-perfect collision**: read the sprite graphics data and check if any non-transparent pixels overlap.

This is slower (10-100x slower than bounding boxes) but necessary for organic shapes (enemies that aren't rectangles).

Implementation: Read the sprite frame data, check if pixels at (bx, by) and (ex, ey) are both non-transparent.

For now, bounding boxes are sufficient. After you complete this tutorial, see the Collision API reference for pixel-perfect techniques.

---

## Scoring & Win Conditions

Add a score variable:

```asm
score equ $7FFF                ; Address of score variable in RAM

* When enemy dies
        lda   score + 1
        adda  #10
        sta   score + 1
        bcc   no_score_carry
        lda   score
        adda  #1
        sta   score
no_score_carry:
```

Set a win condition (all enemies defeated or certain number of waves survived):

```asm
OnEnemyDeath:
        jsr   IncrementScore
        
        * Check if all enemies defeated
        ldx   #EnemyTable
        lda   #0
        stx   <enemy_count
        
enemy_count_loop:
        lda   sprite_active,x
        beq   no_count_this
        inca
        stx   <enemy_count
        
no_count_this:
        leax  SpriteStride,x
        cmpx  #EnemyTableEnd
        bne   enemy_count_loop
        
        cmpa  #0                    ; Any enemies left?
        bne   still_enemies
        
        * All enemies defeated
        lda   #2                    ; State = won
        sta   game_state
        rts
        
still_enemies:
        rts
```

---

## What You've Built

By now, you have a complete game:

1. **Step 00**: One sprite you can move with the joypad
2. **Step 01**: Multiple animated sprites (player, enemies, bullets)
3. **Step 02**: Button input to fire bullets
4. **Step 03**: Collisions, scoring, and win conditions

**Congratulations!** You've built a real Thomson TO8 game. It has:

- ✓ Graphics rendering
- ✓ Object management
- ✓ Input handling
- ✓ Collision detection
- ✓ Game state & scoring

This is the core loop of every game: init, input, update, render. Everything else (sound, levels, palette effects, complex AI) builds on this foundation.

---

## What's Next

The **Extending** section (Steps 04-07) adds:

- **Step 04**: More collision types (collectibles, traps)
- **Step 05**: Sound & music
- **Step 06**: Level management & scrolling
- **Step 07**: Palette effects & visual polish

You now understand the engine well enough to explore those topics independently. The pattern is always the same: allocate space, initialize state, update in a loop, render.

---

## Deep Dive: API Reference

- **Collision Detection API** → `api-reference/collision-api.md`
  - Bounding box math
  - Pixel-perfect collision
  - Collision callbacks
  - Performance optimization & spatial partitioning

- **Object Management API** → `api-reference/object-management-api.md`
  - Game state machines
  - Entity lifecycle
  - Object pool patterns

- **Game State Patterns** → `api-reference/game-state-api.md`
  - Score tracking
  - Win/lose conditions
  - Pause & resume
  - Menu navigation

---

## Summary

You've learned:

1. **Bounding box collision**: Check overlaps on each axis
2. **Separating axis theorem**: If there's a gap on any side, no collision
3. **Collision response**: Despawn, spawn particles, update state
4. **Game state**: Track playing/game-over/won
5. **Scoring**: Increment on events, check win condition
6. **Broad-phase filtering**: Skip distant sprites before detailed checks

You now have a complete game engine. The next steps (sound, levels, polish) are optional. You have everything needed to build and ship a game.

**You're done!** You've completed the Getting Started tutorial. 

---

## Further Exploration

### Study Real Games

Open `/game-projects/`:
- **Goldorak** — Large project, multiple game modes, advanced collision
- **R-Type** — Side-scrolling shooter, bullet hell, particle effects
- **Bubble Bobble** — Platformer, complex level design, AI

Each uses the patterns you learned, expanded with more subsystems.

### Build Your Own Game

You have everything you need:
1. Copy a template
2. Add more sprites and collision types
3. Add new levels
4. Add sound and music (Step 05)

Start small. Add one feature at a time. That's how the real games were built.

### Next Tutorial Section

When ready, proceed to **Extending** (Steps 04-07) for advanced topics.

**Congratulations on completing the Getting Started tutorial!**
