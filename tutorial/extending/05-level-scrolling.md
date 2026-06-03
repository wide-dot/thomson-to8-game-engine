# Step 05: Level Scrolling

**Objective**: Create a scrolling level larger than the screen; camera follows the player; tile-based collision prevents walking through walls.

**Time**: 40-50 minutes

**Build on**: Step 03 (collision detection) or Step 04 (audio)

---

## Subsystems in Play

- **Level Management** — Load tile maps, manage level data
- **Graphics** — Camera viewport, tile rendering from ROM/disk
- **Object Management** — Player constrained to walkable tiles
- **Collision Detection** — Wall collision (impassable vs. walkable)

This step expands the single-screen game to multi-screen levels. Camera follows the player; rendering only visible tiles.

---

## Walkthrough: Tile-Based Levels

Thomson games typically use **tile maps**: a 2D grid where each cell holds a tile ID (0-255).

### Level Memory Layout

```
Level data stored as:
- Width (1 byte) - e.g., 32 tiles
- Height (1 byte) - e.g., 16 tiles
- Tile data (width * height bytes) - one byte per tile

Example: 32x16 level = 512 bytes

In memory:
$7000-$71FF   Tile map (32 x 16 = 512 tiles)
$7200-$75FF   Tile graphics (1KB per tile, 4 tiles in ROM)
$8000+        Level ROM/disk data
```

### Tile IDs and Graphics

Each tile ID maps to graphics data:

```
Tile 0 = empty/walkable space (16x16 pixels)
Tile 1 = wall (solid, impassable)
Tile 2 = water (solid for player, passable for bullets)
Tile 3 = collectible (passable, triggers event)

Tile graphics stored in ROM:
Each tile is 16x16 pixels = 256 bytes in 16-color mode
Tile table at $8000:
  Tile 0 graphics: $8000-$80FF
  Tile 1 graphics: $8100-$81FF
  Tile 2 graphics: $8200-$82FF
  Tile 3 graphics: $8300-$83FF
```

### Camera & Viewport

The screen shows a 20x12 tile viewport (320x192 pixels). The camera position determines which tiles are visible:

```
Camera X, Camera Y = top-left corner of viewport (in tiles)

Visible tiles: Camera to Camera + viewport size

When player moves:
  If player_x < camera_x + 5 → scroll left (camera_x -= 1)
  If player_x > camera_x + 14 → scroll right (camera_x += 1)
  Same for Y
```

---

## Code Template: Level Management

### Load Level

```asm
LoadLevel:
        * Load level 1 from ROM at $8000

        lda   #>$8000
        sta   <level_addr_high
        lda   #<$8000
        sta   <level_addr_low

        * Read width
        lda   @$8000
        sta   <level_width

        * Read height
        lda   @$8001
        sta   <level_height

        * Copy tile map to RAM
        ldx   #0
        ldy   #0

level_copy_loop:
        lda   @(level_addr_high:level_addr_low),x
        sta   $7000,x               ; Store in RAM

        inx
        * Continue until (width * height) tiles copied
        cmpa  <level_width
        bne   level_copy_loop

        * Load tile graphics
        jsr   LoadTileGraphics

        * Initialize camera at player start position
        lda   #0
        sta   <camera_x
        sta   <camera_y

        rts
```

### Tile Graphics Lookup

```asm
LoadTileGraphics:
        * Copy all 4 tile graphics (4KB total) to RAM buffer
        * Source: ROM $8100, Destination: $7200

        ldx   #0
tiles_load_loop:
        lda   @($8100,x)
        sta   $7200,x

        inx
        cmpx  #$1000                ; 4KB = $1000 bytes
        bne   tiles_load_loop

        rts
```

### Render Level (Tile Viewport)

```asm
RenderLevel:
        * Render tiles from camera position
        * Camera at (camera_x, camera_y)
        * Viewport: 20 tiles wide, 12 tiles tall

        ldx   #0                    ; Tile index
        ldy   #0                    ; Screen Y (pixels)

viewport_y_loop:
        cpy   #192                  ; Screen height in pixels
        bge   viewport_done

        lda   #0
        sta   <screen_x             ; Reset X

viewport_x_loop:
        lda   <screen_x
        cmpa  #320
        bge   viewport_y_next

        * Calculate tile position
        lda   <screen_x
        lsra
        lsra
        lsra
        lsra                        ; Divide by 16 = tile X
        adda  <camera_x
        sta   <tile_x

        * Same for Y
        sty   <temp_y
        lda   <temp_y
        lsra
        lsra
        lsra
        lsra
        adda  <camera_y
        sta   <tile_y

        * Get tile ID
        lda   <tile_y
        mula  <level_width
        adda  <tile_x
        ldx   #$7000
        lda   a,x                   ; Get tile ID from map

        * Draw tile
        ldx   #0
        ldy   <temp_y
        jsr   DrawTile

        * Next screen X
        lda   <screen_x
        adda  #16
        sta   <screen_x
        bra   viewport_x_loop

viewport_y_next:
        ldy   <temp_y
        ldy   16,y
        bra   viewport_y_loop

viewport_done:
        rts
```

### Draw Single Tile

```asm
DrawTile:
        * A = tile ID
        * X = screen X (pixels)
        * Y = screen Y (pixels)
        * Draw 16x16 tile from graphics buffer

        * Calculate tile graphics address
        * Each tile is 256 bytes; tile ID * 256
        sta   <tile_id
        lda   <tile_id
        mula  #256
        adda  #<$7200
        sta   <tile_gfx_addr

        * Draw tile (call graphics routine from Step 00)
        jsr   DrawSprite16x16        ; Uses tile_gfx_addr, X, Y

        rts
```

---

## Camera Following Player

Update camera position every frame:

```asm
UpdateCamera:
        * Player position is at (player_x, player_y)
        * Center camera on player with margin

        lda   <player_x
        suba  #8                    ; Offset (keep player 8 tiles from left)
        sta   <camera_x

        * Clamp to level bounds
        bges  cam_x_ok
        lda   #0
        sta   <camera_x
cam_x_ok:
        lda   <camera_x
        adda  #20                   ; Viewport width
        cmpa  <level_width
        bls   cam_y_check
        lda   <level_width
        suba  #20
        sta   <camera_x
cam_y_check:
        lda   <player_y
        suba  #6                    ; Offset for Y
        sta   <camera_y

        * Similar Y clamp
        bges  cam_y_ok
        lda   #0
        sta   <camera_y
cam_y_ok:
        lda   <camera_y
        adda  #12
        cmpa  <level_height
        bls   camera_done
        lda   <level_height
        suba  #12
        sta   <camera_y
camera_done:
        rts
```

---

## Tile Collision: Walking Through Walls

When the player presses a direction, check if the destination tile is walkable:

```asm
UpdatePlayerWithTileCollision:
        * Y = player sprite
        * Read joypad and move only if tile is walkable

        ldx   #$E7CC                ; Port A (directional)
        lda   ,x
        sta   <joypad_state

        * Check right movement
        bita  #$04                  ; Right bit
        beq   check_left

        * Calculate destination tile
        lda   x_pos,y
        adda  #2                    ; Proposed movement
        lsra
        lsra
        lsra
        lsra                        ; Convert pixels to tiles
        sta   <dest_tile_x

        lda   y_pos,y
        lsra
        lsra
        lsra
        lsra
        sta   <dest_tile_y

        * Look up tile ID
        lda   <dest_tile_y
        mula  <level_width
        adda  <dest_tile_x
        ldx   #$7000
        lda   a,x                   ; Get tile ID

        * Check if walkable (assume tile 0 = walkable)
        beq   can_move_right        ; Tile 0 is OK

        * Tile 1+ is impassable; don't move
        bra   check_left

can_move_right:
        lda   x_pos,y
        adda  #2
        sta   x_pos,y

check_left:
        lda   <joypad_state
        bita  #$08                  ; Left bit
        beq   check_down

        * Similar logic for left movement
        lda   x_pos,y
        suba  #2
        lsra
        lsra
        lsra
        lsra
        sta   <dest_tile_x

        lda   y_pos,y
        lsra
        lsra
        lsra
        lsra
        sta   <dest_tile_y

        lda   <dest_tile_y
        mula  <level_width
        adda  <dest_tile_x
        ldx   #$7000
        lda   a,x

        beq   can_move_left
        bra   check_down

can_move_left:
        lda   x_pos,y
        suba  #2
        sta   x_pos,y

check_down:
        lda   <joypad_state
        bita  #$02                  ; Down bit
        beq   check_up

        lda   x_pos,y
        lsra
        lsra
        lsra
        lsra
        sta   <dest_tile_x

        lda   y_pos,y
        adda  #2
        lsra
        lsra
        lsra
        lsra
        sta   <dest_tile_y

        lda   <dest_tile_y
        mula  <level_width
        adda  <dest_tile_x
        ldx   #$7000
        lda   a,x

        beq   can_move_down
        bra   check_up

can_move_down:
        lda   y_pos,y
        adda  #2
        sta   y_pos,y

check_up:
        lda   <joypad_state
        bita  #$10                  ; Up bit
        beq   player_done

        lda   x_pos,y
        lsra
        lsra
        lsra
        lsra
        sta   <dest_tile_x

        lda   y_pos,y
        suba  #2
        lsra
        lsra
        lsra
        lsra
        sta   <dest_tile_y

        lda   <dest_tile_y
        mula  <level_width
        adda  <dest_tile_x
        ldx   #$7000
        lda   a,x

        beq   can_move_up
        bra   player_done

can_move_up:
        lda   y_pos,y
        suba  #2
        sta   y_pos,y

player_done:
        rts
```

### Tile Type Constants

```asm
TILE_EMPTY       equ 0              ; Walkable, passable
TILE_WALL        equ 1              ; Solid, impassable
TILE_WATER       equ 2              ; Solid for player, passable for bullets
TILE_COLLECTIBLE equ 3              ; Passable, triggers pickup event
```

---

## Level Data Format (ROM)

Create levels as binary data:

```asm
Level1:
        fcb   32                    ; Width
        fcb   16                    ; Height
        fcb   $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
        fcb   $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
        fcb   $01,$00,$01,$01,$00,$00,$00,$00,$01,$01,$00,$00,$00,$00,$00,$01
        fcb   $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
        fcb   $01,$00,$00,$00,$01,$01,$01,$00,$00,$00,$00,$00,$01,$01,$00,$01
        fcb   $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
        fcb   $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
        fcb   $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
        fcb   $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
        fcb   $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
        fcb   $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
        fcb   $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
        fcb   $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
        fcb   $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
        fcb   $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
        fcb   $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01

        * Tile graphics follow here...
```

---

## Real-World Example: R-Type Level Design

Open `/game-projects/r-type/` and examine:
- Level tile maps in `levels/`
- Camera system in `game-mode/00/main.asm`
- Tile collision routines

R-Type patterns:
1. Load level from disk
2. Camera scrolls with player (smooth, not tile-snapped)
3. Enemies spawn based on camera position
4. Bullets can destroy walls (dynamic tile changes)

---

## Integration with Existing Game

Modify your main loop:

```asm
MainLoop:
        jsr   ReadJoypad

        lda   game_state
        beq   state_playing
        bra   state_other

state_playing:
        ldy   #PlayerTable
        jsr   UpdatePlayerWithTileCollision    ; NEW: tile-aware movement
        jsr   UpdateEnemies
        jsr   UpdateBullets
        jsr   CheckCollisions

        jsr   UpdateCamera                      ; NEW: follow player

        jsr   RenderLevel                       ; NEW: tile-based rendering
        jsr   RenderSprites

        bra   main_loop_end

state_other:
        * Handle game over, pause, etc.

main_loop_end:
        jsr   WaitVBL
        bra   MainLoop
```

---

## Performance Optimization

With a 32x16 tile level and 16-pixel tiles, rendering all tiles is expensive (512 draw calls per frame). Optimize by only rendering visible tiles:

```asm
RenderLevelOptimized:
        * Only render tiles within viewport bounds
        * Camera at (camera_x, camera_y); viewport 20x12

        lda   <camera_y
        sta   <tile_y_start

        lda   <camera_y
        adda  #12
        sta   <tile_y_end

        ldy   <tile_y_start
viewport_y_loop:
        cpy   <tile_y_end
        bge   viewport_done

        ldx   <camera_x
viewport_x_loop:
        cmpx  #20                   ; Viewport width
        bge   viewport_y_next

        * Calculate screen pixel coords
        lda   <camera_x
        suba  <camera_x
        lsla
        lsla
        lsla
        lsla                        ; Tile X to pixel X

        * Get tile ID
        lda   y
        mula  <level_width
        adda  x
        sta   <tile_offset
        ldx   #$7000
        lda   a,x

        * Draw tile
        ldx   <tile_x_pixel
        ldy   <tile_y_pixel
        jsr   DrawTile

        inx
        bra   viewport_x_loop

viewport_y_next:
        iny
        bra   viewport_y_loop

viewport_done:
        rts
```

---

## Collision Variants

Different tiles have different behaviors:

```asm
IsTileWalkable:
        * A = tile ID, returns Z=1 if walkable

        cmpa  #TILE_EMPTY
        beq   yes_walkable

        cmpa  #TILE_COLLECTIBLE
        beq   yes_walkable

        lda   #0                    ; Not walkable
        rts

yes_walkable:
        lda   #1
        rts
```

---

## What You've Built

Your game now has:

1. **Tile-based levels** — Load from ROM, render with camera
2. **Scrolling camera** — Follows player, constrained to level bounds
3. **Wall collision** — Player can't walk through walls
4. **Tile variants** — Walkable, wall, collectible (extensible)

This is a **complete scrolling platformer engine**.

---

## What's Next

The **Extending** tutorials continue with:

- **Step 06**: Advanced collision — Multi-object responses, hit reactions

After Step 05, you can:
1. Create large multi-screen levels
2. Add NPCs that respect tile collision
3. Design puzzle rooms with walls and paths

---

## Modifications & Challenges

1. **Smooth scrolling** — Camera scrolls by pixels, not tiles
2. **Dynamic tiles** — Allow bullets to destroy walls, create new paths
3. **Collectibles** — Walk over tile 3 to gain points/power-ups
4. **Multiple levels** — Load different levels on completion
5. **Animated tiles** — Cycle tile graphics to show water flowing

---

## Deep Dive: API Reference

- **Level Management API** → `api-reference/level-management-api.md`
  - Tile map format
  - Camera mechanics
  - Performance optimization

- **Graphics API** → `api-reference/graphics-api.md`
  - Tile rendering
  - Viewport culling

---

## Summary

You've learned:

1. **Tile maps**: 2D grid of tile IDs
2. **Camera system**: Follow player, clamp to level bounds
3. **Tile collision**: Check destination tile before moving
4. **Rendering**: Draw tiles in viewport
5. **Level data**: ROM-based or disk-loaded tile maps

Your game is now **spatially expansive** — from a 320x192 pixel screen to levels of any size.

---

## Further Exploration

### Study R-Type Levels

Examine `/game-projects/r-type/` for:
- Tile-based level design
- Smooth camera scrolling (not tile-snapped)
- Enemy spawn zones (triggered by camera position)
- Multiple level formats

### Advanced Topics

1. **Chunk-based streaming** — Load/unload level data as camera moves (for very large levels)
2. **Parallax scrolling** — Background tiles move at different speeds
3. **Dynamic tile updates** — Change tile IDs during gameplay (destruction, bridges appearing)

For now, 32x16 tile levels are sufficient for most games.

---

## Congratulations!

You've completed **Step 05: Level Scrolling**.

Your game now has:
- ✓ Graphics rendering (Step 00)
- ✓ Object management (Step 01)
- ✓ Input handling (Step 02)
- ✓ Collision detection (Step 03)
- ✓ Sound & music (Step 04)
- ✓ **Level scrolling (Step 05)**

You've built a **complete level-based game engine** with scrolling camera, tile collision, and multi-screen exploration.

**Ready for more?** Proceed to Step 06: Advanced Collision.