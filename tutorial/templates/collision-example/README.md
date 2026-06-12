# Collision Detection Example

Minimal code showing how to detect collisions between two objects using AABB (Axis-Aligned Bounding Box).

## What This Does

- Defines objects with position and size
- Performs AABB collision tests
- Handles collision responses

## How to Adapt

1. **Define your objects**:
   ```asm
   Player:
       fcb 100         ; X = 100
       fcb 100         ; Y = 100
       fcb 16          ; Width = 16
       fcb 16          ; Height = 16
   ```

2. **Implement collision response**:
   ```asm
   HandleCollision:
       ; Remove enemy
       jsr DestroyEnemy
       ; Award points
       jsr AddScore
       rts
   ```

3. **Check multiple collisions**:
   ```asm
   ; Check player vs all enemies
   ldu #Player
   ldx #Enemy1
   jsr CheckCollision
   beq NoCollision1
   jsr HandleCollision
   NoCollision1:
   ```

## AABB Formula

Two axis-aligned boxes collide if:
```
obj1.x < obj2.x + obj2.w  AND
obj1.x + obj1.w > obj2.x  AND
obj1.y < obj2.y + obj2.h  AND
obj1.y + obj1.h > obj2.y
```

## Object Memory Layout

```
Offset 0: X coordinate
Offset 1: Y coordinate
Offset 2: Width
Offset 3: Height
Offset 4+: Custom data (health, type, etc.)
```

## Using This Example

### Build
```bash
cd tutorial/templates/collision-example
togen build.properties
```

### Run
```bash
to8 dist/collision.fd
```

## What Happens

The player (at 100,100) collides with the enemy (at 120,110). The collision handler bounces the player back and decreases enemy health.

## Advanced Techniques

### Circle Collision
For circular objects, calculate distance:
```asm
dx = obj1.x - obj2.x
dy = obj1.y - obj2.y
distance = sqrt(dx*dx + dy*dy)
if distance < radius1 + radius2: collision
```

### Pixel-Perfect Collision
Compare sprite bitmasks for exact collision detection (slower but more accurate).

### Quadtree Optimization
Divide space into quadrants to avoid checking every object pair (for many objects).

## Real-World Example

See `game-projects/goldorak/` for production collision handling with:
- Multiple collision types
- Layered collision masks
- Bullet-to-enemy detection
- Player-to-platform detection

## Related Documentation

- `tutorial/api-reference/collision-subsystem.md` — Full collision API
- `tutorial/templates/sprite-example/` — Drawing objects to test collisions
- `tutorial/templates/object-example/` — Managing multiple objects
