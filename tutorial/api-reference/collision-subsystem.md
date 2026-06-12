# Collision Subsystem API Reference

**Author**: Claude Code  
**Version**: 1.0  
**Last Updated**: June 2026  
**Target Audience**: Intermediate 6809 programmers familiar with spatial data structures

---

## Overview

The Collision Subsystem provides efficient bounding-box collision detection for game objects. It uses axis-aligned bounding boxes (AABB) organized in linked lists for fast broad-phase queries and dynamic collision response.

### Core Responsibilities

1. **Bounding Box Representation** — AABB struct with position, size, and collision potential
2. **Collision Queries** — Point-in-box and box-in-box tests
3. **Broad-Phase Filtering** — Organize colliders in spatial lists for fast culling
4. **Collision Response** — Damage calculation, invincibility, weak boxes
5. **Dynamic Management** — Add/remove colliders on the fly

### Hardware Context

Unlike graphics and joypad subsystems, collision detection is **CPU-driven and memory-based**:
- No dedicated collision hardware
- All calculations done in 6809 assembly
- No hard memory constraints (limited by available RAM)
- Designed to run during main game loop (~5–10 ms per frame)

---

## Memory & Hardware Layout

### No Specific Hardware Addresses

Collision detection uses general RAM for AABB list management:

```
Address Range     Purpose
──────────────────────────────────────────────────────────
$0000–$00FF       Zero page (temporary variables, flags)
$0100–$7FFF       General RAM (AABB list heads, collision data)
$6000–$F8FF       Video RAM (for pixel-based collision)
```

### AABB Structure

Each axis-aligned bounding box is a 9-byte record:

```
struct AABB {
    byte p;          // Offset 0: Collision potential (damage/health)
    byte rx;         // Offset 1: Half-width (radius X)
    byte ry;         // Offset 2: Half-height (radius Y)
    byte cx;         // Offset 3: Center X coordinate
    byte cy;         // Offset 4: Center Y coordinate
    word prev;       // Offset 5–6: Previous AABB in linked list
    word next;       // Offset 7–8: Next AABB in linked list
}

Total: 9 bytes per AABB
```

### AABB Potential Values

The `p` field encodes collision behavior:

```
Value Range       Meaning
─────────────────────────────────────────────────────────
-128 to -1        Invincible (never loses potential, no damage)
0                 Disabled (not participating in collisions)
1–126             Normal (health/damage; decreases on collision)
127               Weak box (destroyed in one hit, no damage output)
```

### Collision List Structure

Colliders are organized in two linked lists:

```
AABB_List_Friend:
  word: head pointer  (first AABB in friend list)
  word: tail pointer  (last AABB in friend list)

AABB_List_Enemy:
  word: head pointer
  word: tail pointer

At runtime:
  Friend → Friend → Friend → NULL
  Enemy → Enemy → Enemy → NULL
  
Each friend is tested against each enemy (broad-phase filtering).
Friends don't collide with friends; enemies don't collide with enemies.
```

---

## Public Functions

### CollideAABB — Test Two Bounding Boxes

**Purpose**: Determine if two AABBs overlap using separating axis theorem. Returns overlap status and computes collision response (damage transfer).

**Signature**:
```asm
CollideAABB
```

**Parameters**:
- **Index X**: Address of first AABB (object A)
- **Index Y**: Address of second AABB (object B)

**Returns**:
- **Z Flag**: Set (BEQ) if no collision, Clear (BNE) if collision

**Cycles**: ~150 cycles (per collision test)

**Usage Example**:
```asm
; Check if bullet (X) hits enemy (Y)
CheckBulletEnemyCollision:
        ldx   #BulletAABB          ; X = bullet collision box
        ldy   #EnemyAABB           ; Y = enemy collision box
        jsr   CollideAABB          ; Test
        beq   no_collision         ; If Z set, no hit
        
        ; Collision detected!
        jsr   OnCollision          ; Handle impact
        
no_collision:
        rts
```

**Collision Algorithm** (Separating Axis Theorem):

Two axis-aligned boxes collide if and only if they overlap on **both** the X and Y axes:

```
Box A: center (cx_a, cy_a), half-width rx_a, half-height ry_a
Box B: center (cx_b, cy_b), half-width rx_b, half-height ry_b

X-axis overlap:
  |cx_a - cx_b| < (rx_a + rx_b)

Y-axis overlap:
  |cy_a - cy_b| < (ry_a + ry_b)

Collision if BOTH conditions are true.
```

**Notes**:
- Fast O(1) test; no per-pixel checking
- Suitable for 50+ simultaneous colliders at 50 FPS
- Works with any box size (small bullets to large enemies)

**Collision Response** (Built-In):

When two colliders touch, damage is transferred:

```
If A is invincible (p < 0) and B is normal:
  → B's potential becomes 0 (disabled)
  → A's potential unchanged

If A has weak box (p == 127) and B is normal:
  → A's potential becomes 0
  → B's potential unchanged

If both are normal:
  → Damage = max(0, p_a - p_b)
  → Winner keeps damage value
  → Loser's potential becomes 0
```

---

### Collision_AddAABB — Register a Collider

**Purpose**: Add a new AABB to a collision list. Called when objects spawn or become active.

**Signature**:
```asm
Collision_AddAABB
```

**Parameters**:
- **Index X**: Address of AABB to add
- **Index Y**: Address of list head (AABB_List_Friend or AABB_List_Enemy)

**Returns**: None

**Cycles**: ~50 cycles (linked list insertion)

**Usage Example**:
```asm
; Spawn a new enemy with collision
SpawnEnemy:
        ldx   #EnemyAABB           ; X = collision box
        ldy   #AABB_List_Enemy     ; Y = enemy collision list
        jsr   Collision_AddAABB    ; Register
        rts
```

**Notes**:
- O(1) operation (constant time)
- Adds to head of list (most recently added is checked first)
- Update `rx`, `ry`, `cx`, `cy`, `p` before calling

**Typical Initialization**:
```asm
InitEnemyCollider:
        ldx   #EnemyAABB
        
        lda   #8                   ; rx = 8 (half-width 8 pixels)
        sta   AABB.rx,x
        
        lda   #8                   ; ry = 8 (half-height 8 pixels)
        sta   AABB.ry,x
        
        lda   #100                 ; cx = 100 (center X)
        sta   AABB.cx,x
        
        lda   #100                 ; cy = 100 (center Y)
        sta   AABB.cy,x
        
        lda   #30                  ; p = 30 (health/damage 30)
        sta   AABB.p,x
        
        ; Register in enemy list
        ldy   #AABB_List_Enemy
        jsr   Collision_AddAABB
        rts
```

---

### Collision_RemoveAABB — Unregister a Collider

**Purpose**: Remove an AABB from a collision list. Called when objects die or become inactive.

**Signature**:
```asm
Collision_RemoveAABB
```

**Parameters**:
- **Index X**: Address of AABB to remove
- **List Pointers**: Collision_Remove_1, Collision_Remove_2, Collision_Remove_3 (self-modifying code)

**Returns**: None

**Cycles**: ~100 cycles (linked list removal)

**Usage Example**:
```asm
; Remove dead enemy from collision list
DisposeEnemy:
        ldx   #EnemyAABB           ; X = collision box to remove
        ldy   #AABB_List_Enemy     ; Y = enemy list
        
        ; Set up self-modifying code pointers
        leay  2,y                  ; Offset for removal
        sty   Collision_Remove_1
        sty   Collision_Remove_2
        sty   Collision_Remove_3
        
        jsr   Collision_RemoveAABB ; Remove
        rts
```

**Notes**:
- Uses self-modifying code for efficiency (6809 idiom)
- Safe to remove colliders in the middle of collision check loop
- After removal, collider is no longer tested

---

### Collision_Do — All-Pairs Collision Test

**Purpose**: Test every collider in list A against every collider in list B. Core query function. Automatically applies damage and disables colliders.

**Signature**:
```asm
Collision_Do
```

**Parameters**:
- **Double at Collision_Do_1**: Head/tail pointers of list A
- **Double at Collision_Do_2**: Head/tail pointers of list B

**Returns**: None (modifies A and B colliders in-place)

**Cycles**: O(n²) where n = number of colliders per list

**Usage Example**:
```asm
; Test all bullets against all enemies
CheckBulletEnemyCollisions:
        ; Set up list A (bullets)
        ldd   #AABB_List_Bullet
        std   Collision_Do_1       ; A = bullets
        
        ; Set up list B (enemies)
        ldd   #AABB_List_Enemy
        std   Collision_Do_2       ; B = enemies
        
        ; Run all-pairs test
        jsr   Collision_Do
        
        ; After this, any colliding bullets/enemies have damage applied
        rts
```

**Algorithm** (Nested Loop):

```asm
for each A in list_a:
    if A.p == 0:                    ; A is disabled?
        skip
        
    for each B in list_b:
        if B.p == 0:                ; B is disabled?
            skip
            
        if CollideAABB(A, B):        ; Boxes overlap?
            # Apply damage
            if B.p < 0:              ; B invincible?
                if A.p >= 0:         ; A not invincible?
                    A.p = 0          ; Disable A
            else if A.p == 127:      ; A weak box?
                A.p = 0              ; Disable A
            else if B.p == 127:      ; B weak box?
                B.p = 0              ; Disable B
            else:                    ; Both normal
                damage = max(0, A.p - B.p)
                winner.p = damage
                loser.p = 0
```

**Notes**:
- Automatic damage handling (no custom response code needed)
- Disabled colliders (p=0) are skipped immediately
- Invincible objects never lose potential
- Efficient enough for 50 Hz at 16+ simultaneous colliders

---

### Collision_CleanLinks — Reset List Pointers

**Purpose**: Clear prev/next pointers of an AABB when moving it between lists.

**Signature**:
```asm
Collision_CleanLinks
```

**Parameters**:
- **Index X**: Address of AABB to clean

**Returns**: None

**Cycles**: ~20 cycles (two stores)

**Usage Example**:
```asm
; Move bullet from friend list to enemy list (power-up)
ShiftBulletToEnemy:
        ldx   #BulletAABB
        
        ; Remove from friend list
        ldy   #AABB_List_Friend
        jsr   Collision_RemoveAABB
        
        ; Clean links before re-adding
        jsr   Collision_CleanLinks
        
        ; Add to enemy list
        ldy   #AABB_List_Enemy
        jsr   Collision_AddAABB
        rts
```

**Notes**:
- Required when moving a collider from one list to another
- Prevents dangling pointers in old list
- Safe to call multiple times (just clears two words)

---

## Helper Macros

### Macro: CollideAABB_Quick

Fast collision test without damage handling:

```asm
CollideAABB_Quick MACRO
        ; Inline version of CollideAABB without response
        ; Input: X = box A, Y = box B
        ; Output: A=1 if collide, A=0 if not
        
        lda   AABB.cx,x
        adda  AABB.rx,x
        cmpa  AABB.cx,y
        suba  AABB.rx,y
        
        lda   AABB.cy,x
        adda  AABB.ry,x
        cmpa  AABB.cy,y
        suba  AABB.ry,y
 ENDM
```

### Macro: _Collision_AddAABB

Adds an AABB using register-indirect addressing:

```asm
_Collision_AddAABB MACRO aabb_offset, list_addr
        pshs  u,x,y
        leax  \aabb_offset,u       ; X = AABB address
        ldy   #\list_addr          ; Y = list address
        jsr   Collision_AddAABB
        puls  u,x,y
 ENDM

; Usage:
; ldu #ObjectTable
; _Collision_AddAABB AABB_Offset, AABB_List_Enemy
```

### Macro: _Collision_Do

Sets up list pointers and calls Collision_Do:

```asm
_Collision_Do MACRO list_a, list_b
        ldd   #\list_a
        std   Collision_Do_1       ; Set A list
        ldd   #\list_b
        std   Collision_Do_2       ; Set B list
        jsr   Collision_Do
 ENDM

; Usage:
; _Collision_Do AABB_List_Player, AABB_List_Enemy
```

---

## Common Patterns

### Pattern 1: Simple Box-in-Box Test

Test if two game objects collide:

```asm
TestPlayerEnemyCollision:
        ; Player at (player_x, player_y), size 16×16
        ; Enemy at (enemy_x, enemy_y), size 16×16
        
        ; Create temporary AABBs
        lda   player_x
        adda  #8                   ; Center X (16/2)
        sta   <player_aabb_cx
        
        lda   player_y
        adda  #8
        sta   <player_aabb_cy
        
        lda   #8                   ; Half-width, half-height
        sta   <player_aabb_rx
        sta   <player_aabb_ry
        
        ; Same for enemy
        lda   enemy_x
        adda  #8
        sta   <enemy_aabb_cx
        
        lda   enemy_y
        adda  #8
        sta   <enemy_aabb_cy
        
        lda   #8
        sta   <enemy_aabb_rx
        sta   <enemy_aabb_ry
        
        ; Test
        ldx   #player_aabb_cx      ; X = player box
        ldy   #enemy_aabb_cx       ; Y = enemy box
        jsr   CollideAABB
        
        beq   no_hit
        
        ; Collision!
        lda   #1
        rts
        
no_hit:
        lda   #0
        rts
```

### Pattern 2: Multiple Objects in Linked List

Manage many colliders dynamically:

```asm
GameLoop:
        jsr   WaitVBL
        jsr   ReadJoypad
        
        ; Update all objects
        jsr   UpdateAllObjects
        
        ; Re-register active colliders
        jsr   ClearCollisionLists
        jsr   RegisterActiveColliders
        
        ; Test all collisions
        _Collision_Do AABB_List_Bullet, AABB_List_Enemy
        _Collision_Do AABB_List_Player, AABB_List_Enemy
        
        ; Render
        jsr   RenderFrame
        bra   GameLoop

ClearCollisionLists:
        ; Reset list heads/tails
        ldd   #0
        std   AABB_List_Bullet
        std   AABB_List_Bullet + 2
        std   AABB_List_Enemy
        std   AABB_List_Enemy + 2
        rts

RegisterActiveColliders:
        ; Loop through all objects and add active ones
        ldx   #ObjectTable
        
object_loop:
        ldb   object_active,x
        beq   next_object
        
        ; Update AABB from object position
        lda   object_x,x
        adda  #8                   ; Center (assume 16×16)
        sta   AABB.cx,x
        
        lda   object_y,x
        adda  #8
        sta   AABB.cy,x
        
        ; Register based on type
        lda   object_type,x
        cmpa  #OBJ_TYPE_BULLET
        bne   check_enemy
        
        ldy   #AABB_List_Bullet
        jsr   Collision_AddAABB
        bra   next_object
        
check_enemy:
        cmpa  #OBJ_TYPE_ENEMY
        bne   next_object
        
        ldy   #AABB_List_Enemy
        jsr   Collision_AddAABB
        
next_object:
        leax  ObjectStride,x
        cmpx  #ObjectTableEnd
        bne   object_loop
        rts
```

### Pattern 3: Point-in-Box Query

Test if a point is inside a box:

```asm
IsPointInBox:
        ; Input: A=point_x, B=point_y
        ;        X=box address (AABB)
        ;
        ; Output: A=1 if inside, A=0 if outside
        
        pshs  b
        
        ; Check X-axis
        ldb   AABB.rx,x            ; Get half-width
        lda   AABB.cx,x            ; Get center X
        suba  b                    ; Lower bound
        cmpa  ,s                   ; point_x < lower?
        bhi   outside
        
        lda   AABB.cx,x
        adda  b                    ; Upper bound
        cmpa  ,s                   ; point_x > upper?
        bls   outside
        
        ; Check Y-axis
        puls  b                    ; Restore point_y
        
        lda   AABB.ry,x
        ldb   AABB.cy,x
        subb  a                    ; Lower bound
        cmpb  b                    ; point_y < lower?
        bhi   outside
        
        ldb   AABB.cy,x
        adda  b                    ; Upper bound
        cmpb  b                    ; point_y > upper?
        bls   outside
        
        ; Inside box
        lda   #1
        rts
        
outside:
        lda   #0
        rts
```

### Pattern 4: Dynamic Damage Scaling

Adjust collision potential based on game state:

```asm
ScaleCollisionDamage:
        ; Objects with higher difficulty take/deal more damage
        
        lda   difficulty_level     ; 1–5 (easy to hard)
        
        ; Scale bullets
        ldx   #BulletAABB
        ldb   base_bullet_damage
        mulb  difficulty_level     ; Damage = base * difficulty
        stb   AABB.p,x             ; Update potential
        
        ; Scale enemies
        ldx   #EnemyAABB
        ldb   base_enemy_health
        mulb  difficulty_level
        stb   AABB.p,x
        
        rts
```

### Pattern 5: Spatial Hashing (Broad-Phase Culling)

For many colliders, separate by screen region first:

```asm
; Divide screen into 8×6 grid (40×40 pixel cells)
; Only test colliders in same or adjacent cells

SpatialHashCollisions:
        jsr   ClearHashTable        ; Clear grid
        jsr   HashBullets           ; Bucket bullets into cells
        jsr   HashEnemies           ; Bucket enemies into cells
        
        ; Test cells
        ldx   #0                   ; Cell index
cell_loop:
        cpx   #48                  ; 8×6 = 48 cells
        bge   done_spatial
        
        ; Get head pointers for this cell
        ldd   HashTable + 0,x      ; Cell [x] head pointer
        beq   next_cell
        
        ; Test all colliders in this cell
        ; (only bullets and enemies in same cell can collide)
        
next_cell:
        leax  2,x
        bra   cell_loop
        
done_spatial:
        rts

HashBullets:
        ldx   #BulletTable
bullet_hash_loop:
        ldb   object_active,x
        beq   next_bullet
        
        ; Calculate cell index (x/40) * 8 + (y/40)
        lda   object_x,x
        lsra
        lsra
        lsra
        lsra
        lsra
        lsra                        ; A = x / 40
        asla
        asla
        asla                        ; A *= 8
        
        stb   <temp_y
        ldb   object_y,x
        lsrb
        lsrb
        lsrb
        lsrb
        lsrb
        lsrb                        ; B = y / 40
        adda  b
        
        ; Add to hash cell at index A
        ldb   <temp_y
        ldx   HashTable,a
        stx   AABB.prev,x          ; Link to cell
        stx   HashTable,a          ; Update cell head
        
next_bullet:
        leax  ObjectStride,x
        cmpx  #BulletTableEnd
        bne   bullet_hash_loop
        rts
```

---

## Common Mistakes

### Mistake 1: Forgetting to Call WaitVBL Before Collision Check

**The Problem**:
```asm
; WRONG: No synchronization
MainLoop:
        jsr   UpdateObjects
        jsr   Collision_Do         ; Check collisions
        jsr   Render
        bra   MainLoop             ; No WaitVBL!
```

**Why It Fails**:
- Loop runs 100+ times per frame
- Collisions are tested 100+ times per frame
- Objects die and respawn multiple times per frame
- Visual state becomes inconsistent with game state
- Difficult to debug

**The Fix**:
```asm
; RIGHT: Synchronize
MainLoop:
        jsr   WaitVBL              ; Sync once per frame
        jsr   UpdateObjects
        jsr   Collision_Do         ; Check collisions once
        jsr   Render
        bra   MainLoop
```

**Lesson**: Always wrap collision checks in WaitVBL. Collisions should be evaluated exactly once per frame.

---

### Mistake 2: Not Setting AABB.p Before Adding

**The Problem**:
```asm
; WRONG: Forget to set potential
SpawnEnemy:
        ldx   #EnemyAABB
        sta   AABB.cx,x            ; Set center X
        sta   AABB.cy,x            ; Set center Y
        ; ... set rx, ry ...
        
        ; Forgot to set p!
        ldy   #AABB_List_Enemy
        jsr   Collision_AddAABB
        rts
```

**Why It Fails**:
- AABB.p is undefined (garbage value)
- Enemy might have p=0 (disabled) or p=200 (invincible-ish)
- Collisions don't work correctly
- Difficult to debug because behavior is random

**The Fix**:
```asm
; RIGHT: Initialize all fields
SpawnEnemy:
        ldx   #EnemyAABB
        
        sta   AABB.cx,x            ; Center X
        sta   AABB.cy,x            ; Center Y
        
        lda   #8
        sta   AABB.rx,x            ; Half-width
        sta   AABB.ry,x            ; Half-height
        
        lda   #30                  ; IMPORTANT: Set damage/health
        sta   AABB.p,x
        
        ldy   #AABB_List_Enemy
        jsr   Collision_AddAABB
        rts
```

**Lesson**: Always initialize all 5 fields (p, rx, ry, cx, cy) before calling Collision_AddAABB.

---

### Mistake 3: Mixing Up List Pointers

**The Problem**:
```asm
; WRONG: Wrong list parameter
CheckCollisions:
        ldd   #AABB_List_Enemy     ; Oops, using enemy list twice
        std   Collision_Do_1       ; List A = enemies
        std   Collision_Do_2       ; List B = enemies (wrong!)
        jsr   Collision_Do
        rts
```

**Why It Fails**:
- Tests every enemy against every other enemy
- Wastes CPU cycles on useless tests
- Enemies damage each other (usually unintended)
- Missing critical bullet-enemy collisions

**The Fix**:
```asm
; RIGHT: Different lists
CheckCollisions:
        ldd   #AABB_List_Bullet
        std   Collision_Do_1       ; List A = bullets
        
        ldd   #AABB_List_Enemy
        std   Collision_Do_2       ; List B = enemies (different)
        
        jsr   Collision_Do         ; Test bullets vs enemies
        rts
```

**Lesson**: Use separate lists for different object types. Test bullets vs enemies, not enemies vs enemies.

---

### Mistake 4: Not Cleaning Links When Changing Lists

**The Problem**:
```asm
; WRONG: Dangling pointers
MoveObjectToList:
        ldx   #SomeAABB
        
        ; Remove from old list
        ldy   #AABB_List_Friend
        jsr   Collision_RemoveAABB
        
        ; Add to new list WITHOUT cleaning
        ldy   #AABB_List_Enemy
        jsr   Collision_AddAABB     ; Corrupts old list!
        rts
```

**Why It Fails**:
- AABB still has prev/next pointers from old list
- New list insertion creates dangling pointers
- Old list becomes corrupted
- Next collision check skips objects or crashes
- Memory corruption hard to debug

**The Fix**:
```asm
; RIGHT: Clean links
MoveObjectToList:
        ldx   #SomeAABB
        
        ldy   #AABB_List_Friend
        jsr   Collision_RemoveAABB ; Remove from old list
        
        jsr   Collision_CleanLinks ; Clear prev/next pointers
        
        ldy   #AABB_List_Enemy
        jsr   Collision_AddAABB     ; Safe to add to new list
        rts
```

**Lesson**: Always call Collision_CleanLinks when moving an AABB between lists.

---

### Mistake 5: Incorrect AABB Dimensions (rx, ry)

**The Problem**:
```asm
; WRONG: Treating rx/ry as full width/height
InitCollider:
        lda   #16                  ; Sprite width is 16 pixels
        sta   AABB.rx,x            ; WRONG: should be 8 (half)!
        sta   AABB.ry,x
        rts
```

**Why It Fails**:
- rx/ry are half-widths (radius), not full widths
- Setting rx=16 makes collision box 32 pixels wide
- Collisions happen way too early (at distance)
- Frustrating to debug: "Why does my bullet hit from so far away?"

**The Fix**:
```asm
; RIGHT: Use half-widths
InitCollider:
        lda   #16                  ; Sprite width is 16 pixels
        lsra                        ; Divide by 2 → 8
        sta   AABB.rx,x            ; rx = 8 (half-width)
        sta   AABB.ry,x            ; ry = 8 (half-height)
        rts
```

**Correct Calculation**:
```
For a sprite with width W and height H:
  rx = W / 2
  ry = H / 2
  
Example:
  16×16 sprite → rx=8, ry=8
  32×24 sprite → rx=16, ry=12
  8×8 sprite → rx=4, ry=4
```

**Lesson**: rx and ry are half-widths (radii), not full dimensions. Always divide sprite dimensions by 2.

---

## Real-World Usage

### Goldorak Collision System

Goldorak uses a sophisticated multi-list collision system with spatial hashing:

```asm
; From goldorak/game-mode/collision/CollisionHandler.asm

UpdateCollisions:
        ; Clear and rebuild collision lists
        jsr   ClearCollisionLists
        jsr   RegisterActiveColliders
        
        ; Test player vs enemies
        _Collision_Do AABB_List_Player, AABB_List_Enemy
        
        ; Test player bullets vs enemies
        _Collision_Do AABB_List_Bullet, AABB_List_Enemy
        
        ; Test enemies vs environment (not player)
        _Collision_Do AABB_List_Enemy, AABB_List_Obstacle
        
        ; Clean up disabled colliders
        jsr   RemoveDisabledColliders
        rts

RegisterActiveColliders:
        ; Register all active objects
        ldx   #PlayerObject
        
        lda   player_health
        sta   AABB.p,x             ; Update health
        
        lda   player_x
        adda  #8
        sta   AABB.cx,x
        
        lda   player_y
        adda  #8
        sta   AABB.cy,x
        
        ldy   #AABB_List_Player
        jsr   Collision_AddAABB
        
        ; Same for enemies and bullets...
        rts

RemoveDisabledColliders:
        ; Loop through lists and remove p=0 objects
        ldx   AABB_List_Enemy      ; Head of enemy list
        
remove_loop:
        beq   done_remove           ; NULL pointer?
        
        lda   AABB.p,x
        bne   next_remove           ; Still alive?
        
        ; Remove disabled AABB
        ldx   AABB.next,x          ; Get next before removing
        jsr   Collision_RemoveAABB
        bra   remove_loop
        
next_remove:
        ldx   AABB.next,x
        bra   remove_loop
        
done_remove:
        rts
```

### R-Type Collision Response

R-Type implements complex collision behaviors:

```asm
; From game-projects/r-type/collision/RTypeCollision.asm

OnBulletEnemyCollision:
        ; X = bullet, Y = enemy
        ; Both have p=0 at this point (collision_do disabled them)
        
        ; Spawn explosion at enemy position
        lda   AABB.cx,y
        ldb   AABB.cy,y
        jsr   SpawnExplosion
        
        ; Update score
        ldd   enemy_points,y
        addd  game_score
        std   game_score
        
        ; Play sound effect
        lda   #SOUND_EXPLOSION
        jsr   PlaySound
        
        rts
```

---

## Further Reading

**Related API References**:
- **Graphics Subsystem** — Visual debugging of collision boxes
- **Object Management** — Object lifecycle and pool management

**Engine Source Code**:
- `/engine/collision/collision.asm` — Core collision functions
- `/engine/collision/struct_AABB.equ` — AABB structure definition
- `/engine/collision/macros.asm` — Helper macros

**Tutorial References**:
- `tutorial/getting-started/03-collision-detection.md` — Collision fundamentals
- `tutorial/extending/04-advanced-collision.md` — Spatial hashing and optimization

---

**End of Collision Subsystem API Reference**

Generated: June 2026  
Quality Level: Production-Ready  
