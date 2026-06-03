# Object Management API Reference

**Author**: Claude Code  
**Version**: 1.0  
**Last Updated**: June 2026  
**Target Audience**: Intermediate 6809 programmers familiar with Thomson TO8 game systems

---

## Overview

The Object Management API handles creation, update, and lifecycle management of game objects (enemies, projectiles, pickups, hazards). It provides a fixed-size object pool to maximize performance on resource-constrained hardware while enabling dynamic spawning and despawning of entities.

### Core Responsibilities

1. **Object Pool Management** — Maintain 32-object limit with allocation/deallocation
2. **Object State Tracking** — Track position, velocity, animation frame, health, etc.
3. **Object Lifecycle** — Spawning, updating, and destruction callbacks
4. **Object Queries** — Fast lookups for collision detection and rendering
5. **Type-Specific Behavior** — Enemy AI, projectile physics, hazard effects
6. **Memory Efficiency** — Compact per-object data structure (16 bytes each = 512 bytes total)

### Hardware Context

The Thomson TO8 object system:
- **Object Pool**: Maximum 32 concurrent objects (CPU limitation)
- **Memory per Object**: 16 bytes (position, velocity, state, type)
- **Total Pool Size**: 512 bytes ($2000–$21FF in RAM)
- **Sprite Rendering**: Objects rendered after tilemap (priority sorting)
- **Collision Detection**: Object-to-object and object-to-tile testing
- **Update Rate**: All objects updated every VBL (50 Hz)

---

## Memory & Hardware Layout

### Object Pool Structure in RAM

```
Object Pool Base Address: $2000
Total Size: 512 bytes (32 objects × 16 bytes each)

Object Layout (16 bytes):
  Offset    Size    Field
  ─────────────────────────────────────────────
  0         1       Type ID (0=empty, 1=enemy, 2=projectile, 3=pickup)
  1         1       State flags (bit 0: alive, bit 1: animated)
  2         1       X position (pixels)
  3         1       Y position (pixels)
  4         1       Velocity X (signed, pixels/frame)
  5         1       Velocity Y (signed, pixels/frame)
  6         1       Animation frame (0–15)
  7         1       Health / lifetime counter
  8         2       Data 0 (type-specific, e.g., enemy ID or timer)
  10        2       Data 1 (type-specific)
  12        2       Sprite graphics pointer
  14        1       Pad/reserved
```

### Object Pool Address Mapping

```
Object 0:  $2000–$200F
Object 1:  $2010–$201F
Object 2:  $2020–$202F
...
Object 31: $21F0–$21FF

Quick calculation: Object_Address = $2000 + (object_index × 16)

Registers:
  ObjectPtr = $2000 + (index × 16)
```

### Object Type Definitions

```c
// Type IDs
#define OBJ_EMPTY       0
#define OBJ_ENEMY       1
#define OBJ_PROJECTILE  2
#define OBJ_PICKUP      3
#define OBJ_HAZARD      4

// State flags (offset +1)
#define STATE_ALIVE     $01
#define STATE_ANIMATED  $02
#define STATE_SOLID     $04
```

### Global Object Pool State

```
Label               Address   Size   Content
──────────────────────────────────────────────────
object_count        $3100     1      Number of active objects (0–32)
object_free_list    $3101     32     Free object indices (for quick reuse)
object_free_count   $3121     1      Count of free slots

camera_x            $3200     2      Camera position (for viewport culling)
camera_y            $3202     2      (For determining which objects to render)
```

### Per-Object Fields (16-byte structure)

**Byte 0: Type ID**
```
0 = Empty slot (available for spawning)
1 = Enemy (AI-controlled, moves autonomously)
2 = Projectile (bullet, moving rapidly)
3 = Pickup (collectible, stationary or rotating)
4 = Hazard (spikes, lava, moving platform)
```

**Byte 1: State Flags**
```
Bit 0: Alive (1 = active, 0 = dead but in pool)
Bit 1: Animated (1 = animation playing)
Bit 2: Solid (1 = participates in collision)
Bit 3: Visible (1 = render this frame)
```

**Bytes 2–3: Position (X, Y)**
```
8-bit each for pixel coordinates (0–255)
For screen-relative rendering
```

**Bytes 4–5: Velocity (VX, VY)**
```
Signed 8-bit values
+128 to -127 pixels per frame
Negative = upward/leftward movement
```

**Bytes 8–9: Data 0 (Type-Specific)**
```
Enemy: Enemy type ID (0–7)
Projectile: Owner ID (which player/enemy fired it)
Pickup: Item type (gold, health, weapon)
Hazard: Hazard subtype (spikes, lava, moving platform)
```

---

## Public Functions

### SpawnObject — Create new object in pool

```asm
; Spawn a new game object
;
; Entry:
;   A = Object type ID (1=enemy, 2=projectile, 3=pickup)
;   X = World X position (pixels)
;   Y = World Y position (pixels)
;   B = Object subtype (e.g., enemy ID, item type)
;
; Exit:
;   A = Object index (0–31) if successful
;   A = $FF if pool is full (no free slots)
;
; Uses: All registers
;
; Notes:
;   - Maximum 32 objects; returns $FF if limit reached
;   - Object is initialized with provided type, position, subtype
;   - All other fields set to defaults (velocity=0, health=full, etc.)
;   - Object is marked alive and ready for updates

SpawnObject:
        pshs  a,b,x,y         ; Save parameters
        
        ; Find first free object slot
        lda   object_count
        cmp   #32             ; Pool full?
        beq   .pool_full
        
        ; Calculate next object address
        ldb   a               ; B = object count
        lslb
        lslb
        lslb
        lslb                  ; B = count × 16 (4 left shifts)
        leax  $2000,x         ; X = object base + offset
        
        ; Initialize object structure
        puls  a               ; Restore type ID
        sta   ,x              ; Byte 0: type ID
        
        lda   #STATE_ALIVE
        sta   1,x             ; Byte 1: state flags
        
        puls  b               ; Restore subtype (B)
        sta   8,x             ; Byte 8: data 0 (subtype)
        
        puls  x,y             ; Restore position (X, Y)
        stx   2,x             ; Bytes 2–3: position
        sty   4,x             ; Bytes 4–5: velocity (initialized to 0)
        
        ; Clear remaining fields
        clr   6,x             ; Animation frame = 0
        clr   7,x             ; Health = 0 (full)
        
        ; Increment object count
        inc   object_count
        lda   object_count
        suba  #1              ; Return index
        rts
        
.pool_full:
        lda   #$FF            ; Return error
        rts
```

### UpdateObject — Update single object for one frame

```asm
; Update a single object (position, velocity, animation)
;
; Entry:
;   A = Object index (0–31)
;
; Exit:
;   None (object state updated in place)
;
; Uses: All registers
;
; Notes:
;   - Called once per frame for each active object
;   - Applies velocity to position
;   - Increments animation frame
;   - Calls type-specific update handler
;   - Returns early if object is not alive

UpdateObject:
        ; Calculate object address
        ldb   a
        cmpb  #32
        bge   .invalid
        
        lslb
        lslb
        lslb
        lslb                  ; B = index × 16
        leax  $2000,b         ; X = object base
        
        ; Check if alive
        lda   1,x
        anda  #STATE_ALIVE
        beq   .not_alive
        
        ; Apply velocity to position
        lda   2,x             ; Current X
        ldb   4,x             ; Velocity X
        abx   b
        sta   2,x             ; Update X
        
        lda   3,x             ; Current Y
        ldb   5,x             ; Velocity Y
        aby   b
        sta   3,x             ; Update Y
        
        ; Increment animation frame
        lda   6,x
        inca
        anda  #$0F            ; Wrap at 16 frames
        sta   6,x
        
        ; Call type-specific update
        lda   ,x              ; Load type ID
        cmpa  #OBJ_ENEMY
        beq   .update_enemy
        cmpa  #OBJ_PROJECTILE
        beq   .update_projectile
        cmpa  #OBJ_PICKUP
        beq   .update_pickup
        
        rts
        
.update_enemy:
        jsr   UpdateEnemyAI
        rts
        
.update_projectile:
        jsr   UpdateProjectilePhysics
        rts
        
.update_pickup:
        jsr   UpdatePickupRotation
        rts
        
.not_alive:
        rts
        
.invalid:
        rts
```

### DestroyObject — Mark object as dead and free slot

```asm
; Destroy an object and free its pool slot
;
; Entry:
;   A = Object index (0–31)
;
; Exit:
;   None (object removed from active pool)
;
; Uses: All registers
;
; Notes:
;   - Object is marked as not alive (state & ~STATE_ALIVE)
;   - Slot remains in pool but is available for reuse
;   - Type is set to OBJ_EMPTY for visual confirmation
;   - Can be respawned into same slot immediately if needed

DestroyObject:
        ldb   a
        cmpb  #32
        bge   .invalid
        
        ; Calculate address
        lslb
        lslb
        lslb
        lslb
        leax  $2000,b
        
        ; Mark as not alive
        lda   1,x
        anda  #~STATE_ALIVE   ; Clear alive bit
        sta   1,x
        
        ; Set type to empty
        clra
        sta   ,x              ; Type = OBJ_EMPTY
        
        ; Decrement active count
        dec   object_count
        
        rts
        
.invalid:
        rts
```

### GetObjectState — Query object properties

```asm
; Get current state of an object
;
; Entry:
;   A = Object index (0–31)
;   B = Field ID (0=type, 1=state, 2=x, 3=y, 4=vx, 5=vy, 6=frame)
;
; Exit:
;   A = Requested field value
;
; Uses: A, B, X
;
; Notes:
;   - Fast query for collision detection and rendering
;   - Returns field without modification
;   - Returns 0 if object index is invalid

GetObjectState:
        cmpb  #32
        bge   .invalid
        
        ; Calculate object address
        lslb
        lslb
        lslb
        lslb
        leax  $2000,b
        
        ; Load requested field
        ldx   b               ; Restore field ID (B was overwritten by calc)
        lda   a,x             ; Load byte at offset
        rts
        
.invalid:
        clra
        rts
```

### QueryObjectsInRegion — Find objects in bounding box

```asm
; Find all objects overlapping a screen region
; Used for collision detection and rendering
;
; Entry:
;   X = Region X min (pixels)
;   Y = Region Y min (pixels)
;   B = Region width (pixels)
;   A = Region height (pixels)
;
; Exit:
;   memory starting at $3200 contains object indices
;   Byte count in A (0–32)
;
; Uses: All registers
;
; Notes:
;   - Efficient spatial query for viewport culling
;   - Only returns alive objects
;   - Results stored in temporary list at $3200

QueryObjectsInRegion:
        ; Implementation would iterate all objects,
        ; test bounding box intersection,
        ; accumulate matching indices in result list
        
        lda   object_count    ; Start with object count
        
        ldx   #$2000          ; Object pool start
        ldb   #0              ; Result index
        
.loop:
        cmp   #32
        bge   .done
        
        ; Check if object is in region
        ; (bounding box intersection test)
        ; If yes, add to results
        
        leax  16,x            ; Next object
        inca
        bra   .loop
        
.done:
        stb   a               ; Store result count in A
        rts
```

---

## Common Patterns

### Spawning an Enemy

Basic enemy spawn on level load:

```asm
SpawnEnemyWave:
        ; Spawn 4 enemies in formation
        lda   #OBJ_ENEMY       ; Type = enemy
        ldb   #ENEMY_TYPE_GRUNT ; Subtype
        ldx   #50              ; X position
        ldy   #100             ; Y position
        jsr   SpawnObject      ; Enemy 0
        
        ldx   #70
        jsr   SpawnObject      ; Enemy 1
        
        ldx   #90
        jsr   SpawnObject      ; Enemy 2
        
        ldx   #110
        jsr   SpawnObject      ; Enemy 3
        
        rts
```

### Projectile Creation on Player Fire

```asm
FireWeapon:
        ; Player fires projectile
        lda   #OBJ_PROJECTILE  ; Type = projectile
        ldb   player_id        ; Data 0 = owner
        ldx   player_x         ; Spawn at player position
        ldy   player_y
        jsr   SpawnObject      ; Returns object index in A
        
        ; Store index for later tracking
        sta   last_projectile_id
        
        ; Initialize velocity based on direction
        ldb   last_projectile_id
        lslb
        lslb
        lslb
        lslb
        leax  $2000,b
        
        lda   player_direction ; 0=left, 1=right
        beq   .fire_left
        
        lda   #8               ; Rightward velocity
        sta   4,x              ; VX = 8
        bra   .velocity_done
        
.fire_left:
        lda   #-8              ; Leftward velocity
        sta   4,x
        
.velocity_done:
        clr   5,x              ; VY = 0
        rts
```

### Game Loop Updating All Objects

```asm
GameLoop:
        jsr   UpdateInput
        jsr   UpdatePlayer
        
        ; Update all objects
        lda   object_count
        beq   .no_objects
        
        ldb   #0               ; Object index
.update_loop:
        cmpb  object_count
        bge   .objects_done
        
        tba
        jsr   UpdateObject     ; Update object[B]
        incb
        bra   .update_loop
        
.objects_done:
        ; Check collisions between objects and player
        jsr   CheckPlayerObjectCollisions
        
.no_objects:
        jsr   RenderFrame
        jsr   WaitVBL
        bra   GameLoop
```

### Removing Dead Objects

```asm
RemoveDeadObjects:
        ; Clean up dead objects from pool
        lda   object_count
        beq   .done
        
        ldb   #0               ; Index
.scan_loop:
        cmpb  object_count
        bge   .done
        
        ; Check if alive
        lslb
        lslb
        lslb
        lslb
        leax  $2000,b
        
        lda   1,x              ; State flags
        anda  #STATE_ALIVE
        bne   .next_object
        
        ; Object is dead; remove it
        tba
        jsr   DestroyObject
        
.next_object:
        incb
        bra   .scan_loop
        
.done:
        rts
```

---

## Common Mistakes

### Mistake 1: Exceeding Object Pool Limit

**The Problem**:
```asm
; WRONG: No check for pool overflow
SpawnEnemy:
        lda   #OBJ_ENEMY
        ldb   #GRUNT
        ldx   enemy_x
        ldy   enemy_y
        jsr   SpawnObject      ; Returns $FF if full, but we ignore it
        
        ; Code continues assuming object was created
        ; Subsequent object[32] access reads garbage memory
        rts
```

**Why It Fails**:
- When pool is full (32 objects), SpawnObject returns $FF
- Ignoring this value causes accesses to memory beyond pool ($21FF)
- Corrupts game state, crashes, or causes memory leaks

**The Fix**:
```asm
; RIGHT: Check for pool overflow
SpawnEnemy:
        lda   #OBJ_ENEMY
        ldb   #GRUNT
        ldx   enemy_x
        ldy   enemy_y
        jsr   SpawnObject
        
        cmp   #$FF             ; Check for error
        beq   .spawn_failed     ; Pool is full
        
        ; A now contains valid object index
        sta   last_enemy_id
        rts
        
.spawn_failed:
        ; Handle overflow gracefully
        ; Option 1: Destroy oldest non-critical object
        ; Option 2: Skip spawn
        ; Option 3: Remove low-priority enemy
        rts
```

**Lesson**: Always check SpawnObject return value for $FF (pool full). Decide at design time: either cap enemy count, remove non-critical objects, or queue spawns for next frame.

---

### Mistake 2: Dead Objects Still Rendering

**The Problem**:
```asm
; WRONG: Rendering without checking alive flag
RenderObjects:
        lda   object_count
        ldb   #0
.loop:
        cmpb  a
        bge   .done
        
        ; Render object[B] without checking if alive
        jsr   DrawObjectSprite
        
        incb
        bra   .loop
        
.done:
        rts

; Result: Dead enemies, destroyed projectiles still visible on screen
```

**Why It Fails**:
- Alive flag is not checked before rendering
- Dead object slots still contain old position/sprite data
- Visual artifacts: invisible enemies still have sprites drawn
- Collision issues: rendering suggests object exists but isn't alive

**The Fix**:
```asm
; RIGHT: Check alive flag before rendering
RenderObjects:
        lda   object_count
        ldb   #0
.loop:
        cmpb  a
        bge   .done
        
        ; Check if object is alive before rendering
        lslb
        lslb
        lslb
        lslb
        leax  $2000,b
        
        lda   1,x              ; State flags
        anda  #STATE_ALIVE
        beq   .skip_render      ; Skip dead objects
        
        ; Render sprite
        jsr   DrawObjectSprite
        
.skip_render:
        incb
        bra   .loop
        
.done:
        rts
```

**Lesson**: Always check STATE_ALIVE before rendering or updating objects. Dead objects stay in memory until replaced; don't display them.

---

### Mistake 3: Object Address Calculation Off-by-One

**The Problem**:
```asm
; WRONG: Incorrect bit-shift calculation
SpawnObject:
        ldb   object_count     ; e.g., 5
        lslb                   ; B = 10 (only 1 shift!)
        leax  $2000,x
        
        ; Should be: 5 × 16 = 80 bytes offset
        ; Actually calculated: 10 bytes offset
        ; Object 5 address = $2000 + $0A = $200A (wrong!)
        rts
```

**Why It Fails**:
- Objects are 16 bytes each; must multiply by 16 (4 left shifts)
- Single shift multiplies by 2, not 16
- Object addresses overlap; data corruption across multiple objects

**The Fix**:
```asm
; RIGHT: Four left shifts for ×16
SpawnObject:
        ldb   object_count     ; e.g., 5
        lslb                   ; B = 10 (×2)
        lslb                   ; B = 20 (×4)
        lslb                   ; B = 40 (×8)
        lslb                   ; B = 80 (×16)
        leax  $2000,b
        
        ; Object 5 address = $2000 + 80 = $2050 (correct!)
        rts
```

**Lesson**: Object index × 16 requires 4 consecutive left shifts. Verify with: object_addr = $2000 + (index << 4).

---

### Mistake 4: Not Clearing Object Data on Spawn

**The Problem**:
```asm
; WRONG: Partial initialization
SpawnObject:
        ldb   object_count
        lslb
        lslb
        lslb
        lslb
        leax  $2000,b
        
        sta   ,x              ; Set type
        sta   2,x             ; Set X position
        sta   3,x             ; Set Y position
        ; But don't initialize velocity, health, animation frame, etc.
        
        ; Old data remains in object pool
        rts

; Result: New objects inherit velocity/state from previous objects
```

**Why It Fails**:
- Object pool persists across object lifetime
- Old object data isn't cleared when slot is reused
- New object has garbage velocity, animation frame, health
- Behavior is unpredictable and frame-dependent

**The Fix**:
```asm
; RIGHT: Clear all fields on spawn
SpawnObject:
        ldb   object_count
        lslb
        lslb
        lslb
        lslb
        leax  $2000,b
        
        ; Initialize all 16 bytes
        sta   ,x              ; Type
        lda   #STATE_ALIVE
        sta   1,x             ; State
        lda   spawn_x
        sta   2,x             ; X
        lda   spawn_y
        sta   3,x             ; Y
        
        clr   4,x             ; VX = 0
        clr   5,x             ; VY = 0
        clr   6,x             ; Animation frame = 0
        lda   #$FF
        sta   7,x             ; Health = full
        clr   8,x             ; Data 0 = 0
        clr   9,x             ; Data 1 = 0
        clr   10,x            ; Sprite ptr lo = 0
        clr   11,x            ; Sprite ptr hi = 0
        clr   14,x            ; Reserved = 0
        
        rts
```

**Lesson**: Always initialize all 16 object bytes to known values. Never rely on previous object's state carrying over.

---

### Mistake 5: Velocity Applied Every Frame (Physics Double-Application)

**The Problem**:
```asm
; WRONG: Velocity applied in both UpdateObject and type-specific handler
UpdateObject:
        ; Apply velocity
        lda   2,x
        ldb   4,x
        addb  2,x
        sta   2,x
        
        jsr   UpdateEnemyAI    ; Enemy handler also moves
        rts

UpdateEnemyAI:
        ; Apply velocity again (double movement!)
        lda   2,x
        ldb   4,x
        addb  2,x
        sta   2,x
        rts

; Enemy moves 2× expected distance per frame
```

**Why It Fails**:
- Physics is applied twice: once in generic handler, once in type-specific
- Objects accelerate unexpectedly
- Collisions occur at wrong positions
- Behavior varies by object type

**The Fix**:
```asm
; RIGHT: Physics in one place only
UpdateObject:
        ; Apply velocity (generic to all objects)
        lda   2,x
        ldb   4,x
        addb  2,x
        sta   2,x
        
        ; Type-specific updates (don't re-apply velocity)
        lda   ,x              ; Load type
        jsr   UpdateTypeSpecific
        rts

UpdateEnemyAI:
        ; Only AI logic; don't touch position
        ; May update velocity_x, velocity_y for next frame
        jsr   ComputeAIDecision
        rts
```

**Lesson**: Separate velocity application from type-specific behavior. Velocity is applied once in generic handler; type handlers update velocity for *next* frame, not current.

---

## Real-World Usage

### Goldorak Game Example

Goldorak spawns enemies and projectiles dynamically during gameplay:

```asm
; From goldorak/game-mode/EnemySpawner.asm

EnemyWavePatterns:
        ; Wave 1: 3 grunts, 1 elite
        ; Spawn timing controlled by frame counter
        
        lda   spawn_timer
        cmp   #30              ; Spawn grunt 0 at frame 30
        bne   .check_spawn1
        
        lda   #OBJ_ENEMY
        ldb   #GRUNT
        ldx   #50
        ldy   #80
        jsr   SpawnObject
        
.check_spawn1:
        cmp   #60
        bne   .check_spawn2
        
        lda   #OBJ_ENEMY
        ldb   #GRUNT
        ldx   #100
        ldy   #80
        jsr   SpawnObject
        
        ; ... More enemies ...
        
        rts

UpdateGoldorakGameplay:
        inc   spawn_timer
        
        ; Update all objects
        ldb   object_count
        beq   .no_objects
        
        lda   #0
.update_loop:
        cmp   object_count
        bge   .objects_done
        
        jsr   UpdateObject
        inca
        bra   .update_loop
        
.objects_done:
        jsr   CheckCollisions
        jsr   RemoveDeadObjects
        
.no_objects:
        rts
```

### Player Projectiles (R-Type)

R-Type demonstrates rapid projectile spawning:

```asm
; From game-projects/r-type/weapons/FireWeapon.asm

FirePlayerWeapon:
        ; Check if projectile pool has space
        lda   object_count
        cmp   #28              ; Leave room for enemies
        bge   .pool_full
        
        ; Spawn projectile at player position
        lda   #OBJ_PROJECTILE
        ldb   player_id        ; Owner = player
        ldx   player_x
        adda  #4               ; Offset from player center
        ldy   player_y
        jsr   SpawnObject
        
        cmp   #$FF
        beq   .pool_full
        
        ; Initialize projectile velocity
        sta   proj_index
        ldb   proj_index
        lslb
        lslb
        lslb
        lslb
        leax  $2000,b
        
        lda   #12              ; Fast projectile speed
        sta   4,x              ; VX
        clr   5,x              ; VY
        
        jsr   PlaySoundEffect   ; Weapon fire sound
        
.pool_full:
        rts

; Remove off-screen projectiles
UpdateProjectilePhysics:
        ; Check if projectile is off-screen
        lda   2,x              ; X position
        cmp   #0
        blt   .remove
        cmp   #320
        bge   .remove
        
        rts                    ; On-screen, continue
        
.remove:
        ; Remove projectile
        tba
        jsr   DestroyObject
        rts
```

### Boss Fight with Multiple Objects

```asm
; From tutorial/patterns/boss-encounter/

BossEncounter:
        ; Spawn boss
        lda   #OBJ_ENEMY
        ldb   #BOSS_TYPE
        ldx   #160             ; Center screen
        ldy   #50
        jsr   SpawnObject
        sta   boss_id
        
        ; Boss spawns 3 minions during fight
        lda   boss_phase
        cmp   #2
        bne   .no_minions
        
        ; Spawn 2 minion enemies
        lda   #OBJ_ENEMY
        ldb   #MINION
        ldx   #100
        ldy   #100
        jsr   SpawnObject
        
        ldb   #MINION
        ldx   #220
        jsr   SpawnObject
        
.no_minions:
        ; Render all objects
        jsr   RenderFrame
        rts
```

---

## Further Reading

**Related API References**:
- **Collision Detection** — Object-to-object and object-to-tile testing
- **Level Management** — Enemy spawn zones and level loading
- **Graphics Subsystem** — Sprite rendering and animation

**Engine Source Code**:
- `/engine/objects/pool/ObjectPool.asm` — Pool management
- `/engine/objects/update/UpdateObject.asm` — Per-frame updates
- `/engine/objects/query/QueryObjectsInRegion.asm` — Spatial queries
- `/engine/objects/types/` — Type-specific handlers (enemy, projectile, etc.)

**Tutorial References**:
- `tutorial/getting-started/04-object-system.md` — Object pool basics
- `tutorial/extending/04-spawning-enemies.md` — Enemy waves and patterns
- `tutorial/patterns/projectile-system.md` — Weapon and projectile management

---

**End of Object Management API Reference**

Generated: June 2026  
Quality Level: Production-Ready
