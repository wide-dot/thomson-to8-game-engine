# Step 06: Advanced Collision

**Objective**: Handle complex collision scenarios—wall collision, multi-object responses (damage, bounce, pickup), and collision types by enemy behavior.

**Time**: 45-60 minutes

**Build on**: Step 03-05 (previous collision + optional scrolling/sound)

---

## Subsystems in Play

- **Collision Detection** — Multiple collision types & responses
- **Object Management** — State changes on collision (alive → dead, active → inactive)
- **Physics** — Bounce, knockback, damage application
- **Game State** — Health tracking, score updates, win conditions

This step replaces the simple "despawn on hit" system with sophisticated multi-type collision handling.

---

## Walkthrough: Collision Type System

Real games have different collision rules:

```
Bullet ↔ Enemy:      Despawn bullet, damage enemy, spawn particles
Bullet ↔ Wall:       Despawn bullet, no particle (wall is solid)
Bullet ↔ Water:      Pass through (special water tiles)
Player ↔ Enemy:      Take damage, knockback player
Player ↔ Collectible: Add to inventory, despawn item
Player ↔ Wall:       Stop (no penetration, handled by Step 05)
Enemy ↔ Enemy:       Bounce apart (avoid clustering)
```

### Collision Type Constants

```asm
* Collision type definitions
CTYPE_NONE       equ 0              ; No collision
CTYPE_SOLID      equ 1              ; Hard collision (wall, enemy)
CTYPE_DAMAGE     equ 2              ; Damages player (spikes, enemy)
CTYPE_PICKUP     equ 3              ; Collectible (coin, health)
CTYPE_BOUNCE     equ 4              ; Reflects (bouncy wall)
CTYPE_WATER      equ 5              ; Liquid (slow movement)
CTYPE_GOAL       equ 6              ; Level exit

* Sprite structure offsets
x_pos            equ 0
y_pos            equ 1
sprite_active    equ 2
sprite_type      equ 3              ; NEW: determines collision response
collision_type   equ 4              ; NEW: what kind of collision this sprite handles
health           equ 5
x_vel            equ 6
y_vel            equ 7
```

---

## Code Template: Multi-Type Collision System

### Define Sprite Types

```asm
* Sprite type definitions (stored in sprite_type field)
SPRITE_PLAYER    equ 1
SPRITE_ENEMY     equ 2
SPRITE_BULLET    equ 3
SPRITE_PARTICLE  equ 4
SPRITE_PICKUP    equ 5
```

### Collision Matrix

```asm
* Determine response based on sprite_type pair
* Entry format: what happens when A hits B
* Values: no collision, damage, bounce, despawn, etc.

GetCollisionResponse:
        * X = bullet, Y = enemy
        * Returns collision type in A

        lda   sprite_type,x         ; Attacker type
        ldb   sprite_type,y         ; Defender type

        * Quick cases
        cmpa  #SPRITE_BULLET
        bne   not_bullet_hit

        cmpb  #SPRITE_ENEMY
        beq   bullet_hits_enemy

        cmpb  #SPRITE_WALL
        beq   bullet_hits_wall

        cmpb  #SPRITE_PICKUP
        beq   bullet_hits_pickup

not_bullet_hit:
        cmpa  #SPRITE_PLAYER
        bne   not_player_hit

        cmpb  #SPRITE_ENEMY
        beq   player_hits_enemy

        cmpb  #SPRITE_PICKUP
        beq   player_hits_pickup

not_player_hit:
        lda   #CTYPE_NONE           ; Default: no collision
        rts

bullet_hits_enemy:
        lda   #CTYPE_DAMAGE         ; Bullet damages enemy
        rts

bullet_hits_wall:
        lda   #CTYPE_SOLID          ; Bullet despawns
        rts

bullet_hits_pickup:
        lda   #CTYPE_PICKUP         ; Bullet passes through
        rts

player_hits_enemy:
        lda   #CTYPE_DAMAGE
        rts

player_hits_pickup:
        lda   #CTYPE_PICKUP
        rts
```

### Collision Query with Type

```asm
CheckBulletEnemyCollisionsAdvanced:
        * Enhanced version with collision types

        ldx   #BulletTable
bullet_collision_loop:
        lda   sprite_active,x
        beq   bullet_col_next

        * Check this bullet against all enemies
        ldy   #EnemyTable
enemy_collision_loop:
        lda   sprite_active,y
        beq   enemy_col_next

        * Bounding box collision check (from Step 03)
        jsr   CheckCollisionBoxes
        cmpa  #0
        beq   no_hit

        * NEW: Determine response type
        jsr   GetCollisionResponse
        cmpa  #CTYPE_NONE
        beq   no_hit

        * Dispatch to handler based on type
        sta   <collision_type

        lda   <collision_type
        cmpa  #CTYPE_DAMAGE
        beq   response_damage

        cmpa  #CTYPE_SOLID
        beq   response_solid

        cmpa  #CTYPE_PICKUP
        beq   response_pickup

        bra   no_hit

response_damage:
        jsr   OnBulletDamageEnemy    ; X = bullet, Y = enemy
        bra   bullet_col_next

response_solid:
        jsr   OnBulletHitWall        ; X = bullet (despawn only)
        bra   bullet_col_next

response_pickup:
        jsr   OnBulletHitPickup      ; X = bullet, Y = pickup
        bra   bullet_col_next

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

---

## Collision Response Handlers

### Damage Response

```asm
OnBulletDamageEnemy:
        * X = bullet, Y = enemy
        * Reduce enemy health, despawn bullet, spawn particle

        * Decrement enemy health
        lda   health,y
        suba  #1
        sta   health,y

        * Check if enemy dies
        beq   enemy_dies

        * Enemy survives; apply knockback
        lda   x_pos,x
        cmpa  x_pos,y
        bls   knockback_left

knockback_right:
        * Bullet came from left; push enemy right
        lda   x_pos,y
        adda  #4                    ; Knockback distance
        sta   x_pos,y
        bra   despawn_bullet

knockback_left:
        * Bullet came from right; push enemy left
        lda   x_pos,y
        suba  #4
        sta   x_pos,y

despawn_bullet:
        lda   #0
        sta   sprite_active,x       ; Despawn bullet

        * Spawn particle at impact
        lda   x_pos,x
        jsr   SpawnExplosionParticle

        rts

enemy_dies:
        * Health = 0; despawn enemy
        lda   #0
        sta   sprite_active,y

        * Spawn larger explosion
        lda   x_pos,y
        jsr   SpawnExplosion

        * Award points
        lda   score
        adda  #10
        sta   score

        * Despawn bullet
        lda   #0
        sta   sprite_active,x

        rts
```

### Bounce Response

```asm
OnBulletBounce:
        * X = bullet, Y = bounce tile (wall)
        * Reverse bullet direction

        lda   x_vel,x
        nega
        sta   x_vel,x               ; Reverse X velocity

        * Optional: reduce range (lose energy per bounce)
        * lda   x_vel,x
        * lsra
        * sta   x_vel,x

        rts
```

### Pickup Response

```asm
OnPlayerCollectPickup:
        * X = player, Y = pickup item
        * Add to inventory, despawn pickup

        lda   sprite_type,y
        cmpa  #SPRITE_PICKUP
        bne   not_pickup

        * Check pickup subtype
        lda   health,y              ; Subtype stored in health field

        cmpa  #1                    ; Coin?
        beq   collect_coin

        cmpa  #2                    ; Health pack?
        beq   collect_health

        cmpa  #3                    ; Power-up?
        beq   collect_powerup

        bra   despawn_item

collect_coin:
        * Increment coin counter
        lda   coins
        adda  #1
        sta   coins

        * Award points
        lda   score
        adda  #5
        sta   score

        bra   despawn_item

collect_health:
        * Restore player health (up to max)
        lda   health,x
        adda  #10
        cmpa  #100                  ; Max health
        bls   set_health
        lda   #100

set_health:
        sta   health,x
        bra   despawn_item

collect_powerup:
        * Activate power-up state
        lda   #1
        sta   power_up_active

        * Set timeout (100 frames)
        lda   #100
        sta   power_up_timer

despawn_item:
        lda   #0
        sta   sprite_active,y

        * Play pickup sound
        jsr   PlayPickupSound

        rts

not_pickup:
        rts
```

### Player Takes Damage

```asm
OnPlayerHitEnemy:
        * X = player, Y = enemy
        * Reduce health, apply knockback

        lda   health,x
        suba  #10
        sta   health,x

        * Check if dead
        bls   player_dies

        * Apply knockback
        lda   x_pos,y
        cmpa  x_pos,x
        bls   player_knockback_left

player_knockback_right:
        lda   x_pos,x
        suba  #8
        sta   x_pos,x
        bra   enemy_interaction_done

player_knockback_left:
        lda   x_pos,x
        adda  #8
        sta   x_pos,x

enemy_interaction_done:
        * Play hit sound
        jsr   PlayDamageSound

        rts

player_dies:
        * Set game state to game over
        lda   #1
        sta   game_state

        * Play death sound
        jsr   PlayDeathSound

        rts
```

---

## Multi-Object Collision Groups

For performance, check collisions selectively:

```asm
CheckAllCollisions:
        * Bullets vs. Enemies
        jsr   CheckBulletEnemyCollisions

        * Bullets vs. Walls (tile collision already handled in Step 05)

        * Player vs. Enemies
        jsr   CheckPlayerEnemyCollisions

        * Player vs. Pickups
        jsr   CheckPlayerPickupCollisions

        * Enemy vs. Enemy (prevent stacking)
        jsr   CheckEnemyEnemyCollisions

        rts

CheckPlayerEnemyCollisions:
        ldy   #PlayerTable
        ldx   #EnemyTable
player_enemy_loop:
        lda   sprite_active,x
        beq   player_enemy_next

        jsr   CheckCollisionBoxes
        cmpa  #0
        beq   player_enemy_next

        jsr   OnPlayerHitEnemy       ; Defined above

player_enemy_next:
        leax  SpriteStride,x
        cmpx  #EnemyTableEnd
        bne   player_enemy_loop

        rts

CheckPlayerPickupCollisions:
        ldy   #PlayerTable
        ldx   #PickupTable
player_pickup_loop:
        lda   sprite_active,x
        beq   player_pickup_next

        jsr   CheckCollisionBoxes
        cmpa  #0
        beq   player_pickup_next

        jsr   OnPlayerCollectPickup

player_pickup_next:
        leax  SpriteStride,x
        cmpx  #PickupTableEnd
        bne   player_pickup_loop

        rts

CheckEnemyEnemyCollisions:
        * Prevent enemy clustering by pushing apart
        ldx   #EnemyTable
enemy_a_loop:
        lda   sprite_active,x
        beq   enemy_a_next

        ldy   #EnemyTable
enemy_b_loop:
        cpy   x
        beq   enemy_b_next          ; Don't check against self

        lda   sprite_active,y
        beq   enemy_b_next

        jsr   CheckCollisionBoxes
        cmpa  #0
        beq   enemy_b_next

        * Push apart slightly
        lda   x_pos,x
        cmpa  x_pos,y
        bls   push_right
        lda   x_pos,x
        adda  #2
        sta   x_pos,x
        lda   x_pos,y
        suba  #2
        sta   x_pos,y
        bra   enemy_b_next

push_right:
        lda   x_pos,x
        suba  #2
        sta   x_pos,x
        lda   x_pos,y
        adda  #2
        sta   x_pos,y

enemy_b_next:
        leay  SpriteStride,y
        cmpy  #EnemyTableEnd
        bne   enemy_b_loop

enemy_a_next:
        leax  SpriteStride,x
        cmpx  #EnemyTableEnd
        bne   enemy_a_loop

        rts
```

---

## Wall Collision (Tile-Based)

Enhanced from Step 05 to handle different tile types:

```asm
CanWalkOnTile:
        * A = tile ID
        * Returns A=1 if walkable, A=0 if blocked

        cmpa  #0                    ; Empty
        beq   tile_walkable

        cmpa  #3                    ; Collectible (walkable)
        beq   tile_walkable

        cmpa  #5                    ; Water (slow, but walkable)
        beq   tile_walkable

        lda   #0                    ; Wall, spike, etc.
        rts

tile_walkable:
        lda   #1
        rts

CanWalkInWater:
        * Check if player is moving through water tile
        * Reduce speed by half

        lda   y_pos,x
        lsra
        lsra
        lsra
        lsra
        mula  <level_width
        adda  <tile_x
        ldx   #$7000
        lda   a,x

        cmpa  #5                    ; Water tile?
        bne   not_in_water

        * In water; reduce movement speed
        lda   x_vel,x
        lsra                        ; Divide by 2
        sta   x_vel,x

        lda   y_vel,x
        lsra
        sta   y_vel,x

        * Play splash sound occasionally
        lda   <frame_counter
        anda  #$0F
        bne   not_in_water
        jsr   PlayWaterSound

not_in_water:
        rts
```

### Spike Tile Collision

```asm
CheckSpikeTileCollision:
        * Check if player walked into a spike tile
        * Tile ID = 4 is spike

        lda   y_pos,x
        lsra
        lsra
        lsra
        lsra
        mula  <level_width
        adda  <tile_x
        ldx   #$7000
        lda   a,x

        cmpa  #4                    ; Spike tile?
        bne   not_spike

        * Player hit spike; take damage
        lda   health,x
        suba  #5
        sta   health,x

        * Play pain sound
        jsr   PlayPainSound

not_spike:
        rts
```

---

## Broad-Phase Optimization

With many sprites, collision checking is expensive. Use spatial partitioning:

```asm
CheckCollisionsOptimized:
        * Only check collisions for sprites within 64 pixels of player

        ldy   #PlayerTable
        lda   x_pos,y
        sta   <player_x_cache
        lda   y_pos,y
        sta   <player_y_cache

        ldx   #EnemyTable
broad_phase_loop:
        lda   sprite_active,x
        beq   broad_phase_next

        * Quick distance check
        lda   x_pos,x
        suba  <player_x_cache
        absa
        cmpa  #64                   ; 64 pixel max distance
        bhi   broad_phase_next

        lda   y_pos,x
        suba  <player_y_cache
        absa
        cmpa  #64
        bhi   broad_phase_next

        * Within range; do full collision check
        jsr   CheckCollisionBoxes
        cmpa  #0
        beq   broad_phase_next

        * Handle collision
        jsr   GetCollisionResponse
        * ... dispatch handler ...

broad_phase_next:
        leax  SpriteStride,x
        cmpx  #EnemyTableEnd
        bne   broad_phase_loop

        rts
```

---

## Real-World Example: Goldorak Collision System

Open `/game-projects/goldorak/game-mode/gamescreen/main.asm` and search for "collision" or "damage":

Goldorak patterns:

```asm
        * Check weapon hit enemy
        lda   weapon_active,x
        beq   skip_weapon_check

        ldy   #EnemyTable
enemy_hit_loop:
        lda   sprite_active,y
        beq   enemy_hit_next

        * Bounding box check
        jsr   CheckWeaponEnemyCollision
        beq   enemy_hit_next

        * Determine enemy health
        lda   enemy_health,y
        suba  #weapon_damage,x
        sta   enemy_health,y
        beq   enemy_dies

        * Knockback
        lda   weapon_x,x
        suba  enemy_x,y
        bhs   knock_right
        lda   enemy_x,y
        adda  #weapon_knockback,x
        sta   enemy_x,y
        bra   enemy_hit_next

knock_right:
        lda   enemy_x,y
        suba  #weapon_knockback,x
        sta   enemy_x,y

enemy_hit_next:
        leay  EnemyStride,y
        cmpy  #EnemyTableEnd
        bne   enemy_hit_loop

skip_weapon_check:
```

Goldorak also handles:
1. **Weapon durability** — Weapons degrade on use
2. **Enemy armor** — Different enemy types have different health
3. **Critical hits** — Random bonus damage
4. **Combo system** — Multiple hits in succession

---

## Health & Status Tracking

Enhance game state with health bars, status effects:

```asm
UpdateGameStatus:
        * Called once per frame to update displays

        ldy   #PlayerTable

        * Update health display (HUD)
        lda   health,y
        cmpa  #50
        bhi   health_high

        cmpa  #25
        bhi   health_medium

        * Low health; flash warning
        lda   <frame_counter
        anda  #$10
        beq   health_hidden

health_display:
        * Draw red health bar
        jsr   DrawHealthBar

health_hidden:
        bra   health_done

health_medium:
        * Draw yellow health bar
        jsr   DrawHealthBar

health_high:
        * Draw green health bar
        jsr   DrawHealthBar

health_done:
        * Update status effects
        lda   <power_up_timer
        beq   no_powerup_active

        deca
        sta   <power_up_timer

        beq   power_up_expires
        bra   powerup_active

power_up_expires:
        * End power-up
        lda   #0
        sta   power_up_active
        jsr   PlayPowerUpExpireSound

powerup_active:
        * During power-up, play sparkle effect
        lda   <frame_counter
        anda  #$03
        bne   no_powerup_active
        jsr   SpawnPowerUpParticle

no_powerup_active:
        rts
```

---

## Performance: Collision Cost Analysis

For a game with:
- 1 player
- 8 enemies
- 16 bullets
- 10 pickups

Collisions checked per frame:
- Bullets vs. Enemies: 16 × 8 = 128 checks
- Player vs. Enemies: 1 × 8 = 8 checks
- Player vs. Pickups: 1 × 10 = 10 checks
- Enemy vs. Enemy: 8 × 8 = 64 checks

Total: 210 checks/frame at 50 FPS = 10,500 checks/second

With broad-phase filtering (only 50% overlap range):
- 50% of above = 5,250 checks/second

Acceptable for 6809 (can do ~100,000 simple checks/second).

---

## What You've Built

Your game now has:

1. **Multi-type collisions** — Different responses for different object pairs
2. **Health & damage** — Enemies take damage, player has health
3. **Knockback physics** — Objects push apart on collision
4. **Pickups** — Collectible items with inventory tracking
5. **Tile collision** — Player can't walk through walls, special tiles (water, spikes)
6. **Broad-phase optimization** — Skip distant sprites
7. **Status effects** — Power-ups, health tracking, visual feedback

This is a **production-quality collision system** suitable for complex games.

---

## What's Next

You've now completed the **Extending** tutorials:

- ✓ Step 04: Sound & music
- ✓ Step 05: Level scrolling
- ✓ Step 06: Advanced collision

**You have a complete game engine.** You can now:
1. Build standalone games with all core features
2. Extend with more enemy types, levels, and mechanics
3. Study `/game-projects/` for advanced techniques

---

## Modifications & Challenges

1. **Status effects** — Freeze, poison, slow (reduce velocity)
2. **Pushable objects** — Blocks that move when hit
3. **Chain reactions** — One explosion triggers adjacent explosions
4. **Soft collisions** — Overlapping allowed, but damages player (status effect)
5. **Combo damage** — Hitting same enemy multiple times increases damage
6. **Invincibility frames** — Short period after damage where player can't be hurt again

---

## Deep Dive: API Reference

- **Collision Detection API** → `api-reference/collision-api.md`
  - Bounding box collision
  - Pixel-perfect collision
  - Collision type matrix
  - Performance optimization strategies

- **Object Management API** → `api-reference/object-management-api.md`
  - Sprite pooling
  - Health & damage tracking
  - State machine patterns

- **Physics API** → `api-reference/physics-api.md`
  - Knockback calculations
  - Velocity & acceleration
  - Water/friction simulation

---

## Summary

You've learned:

1. **Collision types**: Different responses for different pairs
2. **Damage system**: Health tracking, damage application, death handling
3. **Knockback physics**: Push objects apart on collision
4. **Pickup system**: Collectible items with inventory
5. **Tile variants**: Water (slow), spikes (damage), walls (impassable)
6. **Broad-phase filtering**: Optimize by skipping distant objects
7. **Status effects**: Power-ups, invincibility, special conditions

Your game now has **sophisticated, production-quality collision handling** matching modern indie games.

---

## Further Exploration

### Study Goldorak Collision

Examine `/game-projects/goldorak/` for:
- Advanced enemy AI with collision response
- Weapon vs. environment interaction
- Health & damage systems
- Multiple collision layers (player, weapon, enemy, destructible)

### Advanced Topics

1. **Raycasting collision** — Detect collisions along a path (for fast-moving objects)
2. **Polygon collision** — Complex shapes beyond rectangles
3. **Physics engine** — Gravity, momentum, angular rotation
4. **Networked collision** — Handling collisions in multiplayer

For single-player games, the techniques in this step are sufficient.

---

## Congratulations!

You've completed **Step 06: Advanced Collision**.

Your game now has:
- ✓ Graphics rendering (Step 00)
- ✓ Object management (Step 01)
- ✓ Input handling (Step 02)
- ✓ Collision detection (Step 03)
- ✓ Sound & music (Step 04)
- ✓ Level scrolling (Step 05)
- ✓ **Advanced collision (Step 06)**

You've built a **complete, production-quality game engine** for the Thomson TO8. Your engine includes:

- Graphics rendering with sprite support
- Object pooling and lifecycle management
- Keyboard/joypad input
- Physics (collision, knockback, velocity)
- Audio (music playback, sound effects)
- Level management (tile maps, scrolling camera)
- Sophisticated collision handling (types, responses, damage)

**You're now a Thomson TO8 game developer!**

---

## Your Next Steps

### Option 1: Build Your Own Game

Use your engine to create a new game:
1. Design a game concept
2. Create level maps
3. Add sprites and animations
4. Implement enemy AI
5. Test, iterate, ship

### Option 2: Study Production Games

Examine `/game-projects/` to see how professionals build games:
- **Goldorak**: Large multi-level game with complex AI and effects
- **R-Type**: Side-scrolling shooter with sophisticated scrolling
- **Bubble Bobble**: Platformer with AI enemies and physics

Each uses your engine's patterns, expanded with domain-specific features.

### Option 3: Advanced Topics

When ready, explore:
1. **Animation systems** — Sprite frame sequences
2. **AI behavior trees** — Complex enemy intelligence
3. **Particle effects** — Explosion, magic, weather
4. **UI/HUD systems** — Menus, score displays, dialogs
5. **Palette effects** — Color transitions, visual polish

---

## You've Completed the Full Tutorial

From Step 00 (boot) to Step 06 (advanced collision), you've learned:

- **Core Engine**: Boot, graphics, object management
- **Interactivity**: Input, collision, scoring
- **Audio**: Music playback, sound effects
- **Levels**: Tile maps, scrolling camera, complex collision
- **Polish**: Health systems, pickups, visual feedback

**Congratulations on mastering Thomson TO8 game development!**

Now go build something amazing.