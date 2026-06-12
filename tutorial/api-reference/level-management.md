# Level Management API Reference

**Author**: Claude Code  
**Version**: 1.0  
**Last Updated**: June 2026  
**Target Audience**: Intermediate 6809 programmers familiar with Thomson TO8 memory model

---

## Overview

The Level Management API handles loading, rendering, and updating game levels on the Thomson TO8. It manages tilemap data, camera positioning, viewport calculations, and tile-based collision detection, enabling large explorable game worlds within the TO8's 40 KB video RAM constraint.

### Core Responsibilities

1. **Level Data Loading** — Reading tilemap data from disk and decompressing into RAM
2. **Tile Rendering** — Drawing tilemap sections efficiently using cached tile graphics
3. **Camera Positioning** — Tracking player position and keeping viewport centered
4. **Viewport Culling** — Only rendering visible tiles to conserve CPU/bandwidth
5. **Tile Collision Detection** — Fast lookups of solid/passable tiles
6. **Level State Management** — Tracking which doors are open, platforms moved, etc.
7. **Scrolling Control** — Smooth parallax and multi-layer scrolling

### Hardware Context

The Thomson TO8 level system:
- **Video RAM**: $6000–$F8FF (40 KB shared between tilemap render buffer and sprites)
- **Level Data**: Stored on disk (cassette/disk) due to size (typical 4–8 KB per level)
- **Tileset**: Pre-cached graphics in RAM or video memory (16–256 tiles per level)
- **Viewport**: 320×224 pixels (40 tiles × 28 tiles at 8×8 pixel size)
- **Camera Speed**: Typically 2–4 pixels per frame (hardware scrolling not available; software only)

---

## Memory & Hardware Layout

### Level Data Structure in ROM/Disk

```
Header (16 bytes):
  Offset    Size    Content
  ──────────────────────────────────────────────────
  0         2       Magic signature ("LE")
  2         1       Level ID (0–255)
  3         1       Width in tiles (20–40)
  4         1       Height in tiles (20–32)
  5         1       Tileset ID (which set of graphics to use)
  6         1       Music ID for this level
  7         1       Flags (bit 0: has parallax, bit 1: cave theme)
  8         2       Camera start X (pixels)
  10        2       Camera start Y (pixels)
  12        2       Player spawn X (pixels)
  14        2       Player spawn Y (pixels)

Tilemap Data (width × height bytes):
  Each byte represents one tile ID (0–255)
  Tiles 0–127: Passable (background)
  Tiles 128–255: Solid (collision walls)

Collision Metadata (optional):
  For each tile type, define solidity:
    Bit 0: Top-left corner solid?
    Bit 1: Top-right corner solid?
    Bit 2: Bottom-left corner solid?
    Bit 3: Bottom-right corner solid?

Additional Data:
  Sprite spawn points (enemy spawn locations)
  Door/switch locations
  Parallax layer offsets
```

### Level State in RAM

```
Label               Address   Size   Content
──────────────────────────────────────────────────────
level_id            $4000     1      Current level ID
level_width         $4001     1      Width in tiles
level_height        $4002     1      Height in tiles
level_data_ptr      $4003     2      Pointer to tilemap in RAM

camera_x            $4010     2      Camera X position (pixels)
camera_y            $4012     2      Camera Y position (pixels)
camera_target_x     $4014     2      Camera target X (player position)
camera_target_y     $4016     2      Camera target Y (player position)

viewport_tile_x     $4020     1      Leftmost visible tile column
viewport_tile_y     $4021     1      Topmost visible tile row
viewport_tiles_w    $4022     1      Visible tiles width (40÷8 = 5 tiles typically)
viewport_tiles_h    $4023     1      Visible tiles height (224÷8 = 28 tiles typically)

tileset_id          $4030     1      Current tileset ID
tileset_data_ptr    $4031     2      Pointer to tile graphics

parallax_offset_x   $4040     2      Parallax layer X scroll offset
parallax_offset_y   $4041     2      Parallax layer Y scroll offset

level_flags         $4050     1      Bit 0: parallax enabled, Bit 1: cave theme
```

### Tilemap Memory Layout

Tilemap occupies contiguous RAM after level header:

```
Level data on disk: 16-byte header + (width × height) bytes of tile IDs

In RAM after decompression:
  $2000:   Level 1 tilemap (e.g., 32×32 = 1024 bytes)
  $2400:   Level 2 tilemap
  $2800:   Level 3 tilemap
  ...

Each tile ID byte:
  0–127:   Passable tiles (background, collectibles)
  128–255: Solid tiles (walls, platforms)
```

### Tile Graphics Cache

```
Tileset Graphics Layout (in video memory or sprite RAM):
  Each tile is 8×8 pixels, 4-bit color (2 bytes width)
  
  Tile 0:  Bytes 0–15 (8 scanlines × 2 bytes)
  Tile 1:  Bytes 16–31
  ...
  Tile N:  Bytes (N×16)–(N×16+15)
  
Total per tileset: 256 tiles × 16 bytes = 4096 bytes (4 KB)
Multiple tilesets can be cached or swapped during play.
```

---

## Public Functions

### LoadLevel — Load level data from disk/ROM

```asm
; Load a level from storage media
;
; Entry:
;   A = Level ID (0–255)
;
; Exit:
;   Level data loaded into RAM ($2000+)
;   Camera positioned at level start
;   Player sprite positioned at spawn point
;   Tileset graphics cached
;
; Uses: All registers
;
; Notes:
;   - Reads from cassette/disk device (blocking operation)
;   - Takes ~1–2 seconds depending on storage
;   - Initializes level state variables
;   - Does not render or display anything (call RenderLevel)

LoadLevel:
        sta   level_id
        
        ; Load level header and data from disk
        ; (Implementation depends on storage device)
        ; Pseudo-code:
        ;   1. Calculate file offset based on level ID
        ;   2. Read header (16 bytes)
        ;   3. Read tilemap (width × height bytes)
        ;   4. Decompress if needed
        ;   5. Load tileset graphics
        
        ; Initialize level state
        ldx   level_data_ptr
        
        lda   2,x              ; Level width
        sta   level_width
        
        lda   3,x              ; Level height
        sta   level_height
        
        lda   8,x              ; Camera start X
        ldx   9,x
        std   camera_x         ; Set initial camera position
        
        rts
```

### RenderLevel — Draw visible tilemap portion to video memory

```asm
; Render tilemap to video buffer
;
; Entry:
;   Camera position must be set (camera_x, camera_y)
;   Level data loaded (level_data_ptr)
;
; Exit:
;   Tilemap drawn to video memory ($6000–$F8FF)
;
; Uses: All registers
;
; Notes:
;   - Only renders visible viewport tiles (culling optimization)
;   - Tile rendering is CPU-intensive; takes ~10–20 ms per frame
;   - Must be called during VBL (after WaitVBL)
;   - Renders to hidden buffer if double-buffering

RenderLevel:
        ; Calculate viewport bounds in tiles
        lda   camera_x
        lsra
        lsra
        lsra                   ; Divide by 8 to get tile column
        sta   viewport_tile_x
        
        lda   camera_y
        lsra
        lsra
        lsra                   ; Divide by 8 to get tile row
        sta   viewport_tile_y
        
        ; Render each visible tile
        ldy   #0               ; Tile row counter
.row_loop:
        cpy   #28              ; 28 tiles tall (224÷8)
        bge   .done
        
        ldx   #0               ; Tile column counter
.col_loop:
        cpx   #40              ; 40 tiles wide (320÷8)
        bge   .next_row
        
        ; Calculate tile index
        lda   viewport_tile_y
        adda  y
        ldb   level_width
        mul                    ; A = row index
        addb  viewport_tile_x
        addb  x                ; B = column offset
        
        ; Get tile ID from tilemap
        ldx   level_data_ptr
        lda   a,x              ; Load tile ID
        
        ; Draw tile at screen position (x, y)
        ldb   x
        lslb
        lslb
        lslb                   ; B = pixel X (tile_col × 8)
        sty   temp_y
        lda   temp_y
        lslb
        lslb
        lslb                   ; A = pixel Y (tile_row × 8)
        
        jsr   DrawTile         ; Draw one tile
        
        inx
        bra   .col_loop
        
.next_row:
        iny
        bra   .row_loop
        
.done:
        rts
```

### UpdateCamera — Update camera position to follow player

```asm
; Update camera position based on player location
;
; Entry:
;   player_x, player_y = Player sprite position (pixels)
;
; Exit:
;   camera_x, camera_y = Updated camera position
;   Camera clamped to level bounds
;
; Uses: All registers
;
; Notes:
;   - Smooth camera: linearly interpolates toward target
;   - Prevents camera jitter by limiting speed to 2–4 pixels/frame
;   - Clamps to level bounds (0, 0) to (width×8, height×8)
;   - Call every frame before RenderLevel

UpdateCamera:
        ; Calculate camera target (player position)
        lda   player_x
        suba  #160             ; Center on player (320/2 - 160 pixels left of center)
        sta   camera_target_x
        
        lda   player_y
        suba  #112             ; Center on player (224/2 - 112 pixels above center)
        sta   camera_target_y
        
        ; Smooth camera movement (interpolate toward target)
        ; Current approach: linear step toward target
        lda   camera_x
        cmpa  camera_target_x
        beq   .camera_y_done
        blt   .move_right
        
        ; Move left
        suba  #3               ; 3 pixels per frame (smooth scroll speed)
        sta   camera_x
        bra   .camera_y_done
        
.move_right:
        adda  #3
        sta   camera_x
        
.camera_y_done:
        ; Same for Y axis
        lda   camera_y
        cmpa  camera_target_y
        beq   .done
        blt   .move_down
        
        suba  #2               ; Slightly slower vertical scroll
        sta   camera_y
        bra   .done
        
.move_down:
        adda  #2
        sta   camera_y
        
.done:
        rts
```

### GetTileID — Look up tile at world position

```asm
; Get tile ID at given world coordinates
;
; Entry:
;   X = World X position (pixels)
;   Y = World Y position (pixels)
;
; Exit:
;   A = Tile ID (0–255)
;
; Uses: A, B, X, Y (returns tile ID in A)
;
; Notes:
;   - Fast lookup for collision detection
;   - Returns 0 (passable) for out-of-bounds
;   - Called frequently; must be optimized

GetTileID:
        ; Convert pixels to tile coordinates
        txa
        lsra
        lsra
        lsra                   ; X / 8 = tile column
        sta   temp_col
        
        tya
        lsra
        lsra
        lsra                   ; Y / 8 = tile row
        sta   temp_row
        
        ; Bounds check
        cmp   level_height
        bge   .out_of_bounds
        lda   temp_col
        cmp   level_width
        bge   .out_of_bounds
        
        ; Calculate tilemap offset
        lda   temp_row
        ldb   level_width
        mul                    ; A:B = row × width
        adda  temp_col         ; A = index
        
        ; Load tile ID
        ldx   level_data_ptr
        lda   a,x              ; Load tile byte
        rts
        
.out_of_bounds:
        clra                   ; Return passable (0)
        rts
```

---

## Common Patterns

### Basic Level Loading and Rendering

Level load at game start:

```asm
GameStart:
        lda   #1               ; Load level 1
        jsr   LoadLevel         ; Read from disk
        
        ; Position player at spawn point
        lda   $4012            ; Get spawn X from level header
        sta   player_x
        lda   $4013            ; Get spawn Y
        sta   player_y
        
        rts

; Main game loop
MainGameLoop:
        jsr   UpdateInput
        jsr   UpdatePlayer
        jsr   UpdateEnemies
        jsr   UpdateCamera      ; Adjust camera to follow player
        
        jsr   WaitVBL           ; Sync to display
        jsr   RenderLevel       ; Draw tilemap
        jsr   RenderSprites     ; Draw player, enemies, objects
        
        bra   MainGameLoop
```

### Tile-Based Collision Detection

Checking if a position is walkable:

```asm
; Check if player can move to new position
CanPlayerMoveTo:
        ; X, Y = target position
        
        ; Check all four corners of player sprite (8×8 pixels)
        ; Top-left corner
        jsr   GetTileID
        cmp   #128             ; Solid tile?
        bge   .blocked
        
        ; Top-right corner
        leax  7,x              ; Add width
        jsr   GetTileID
        cmp   #128
        bge   .blocked
        
        ; Bottom-left corner
        leax  -7,x
        leay  7,y              ; Add height
        jsr   GetTileID
        cmp   #128
        bge   .blocked
        
        ; Bottom-right corner
        leax  7,x
        jsr   GetTileID
        cmp   #128
        bge   .blocked
        
        ; All corners clear; movement allowed
        clra
        rts
        
.blocked:
        lda   #1               ; Blocked
        rts
```

### Camera Following with Bounds

Keeping camera within level boundaries:

```asm
UpdateCameraBounded:
        jsr   UpdateCamera     ; Normal camera update
        
        ; Clamp camera X to level bounds
        lda   camera_x
        bpl   .x_check_max
        clra                   ; Clamp to 0
        sta   camera_x
        
.x_check_max:
        ldb   level_width
        lslb
        lslb
        lslb                   ; B = level width in pixels
        subb  #320             ; Subtract viewport width
        sta   temp_x_max
        
        cmp   camera_x, temp_x_max
        ble   .y_check
        lda   temp_x_max
        sta   camera_x
        
.y_check:
        ; Same for Y
        lda   camera_y
        bpl   .y_check_max
        clra
        sta   camera_y
        
.y_check_max:
        ldb   level_height
        lslb
        lslb
        lslb                   ; B = level height in pixels
        subb  #224             ; Subtract viewport height
        
        cmp   camera_y, b
        ble   .done
        sta   camera_y
        
.done:
        rts
```

### Parallax Scrolling

Multi-layer background scrolling at different speeds:

```asm
RenderLevelWithParallax:
        ; Layer 0: Far background (parallax offset × 0.3)
        lda   camera_x
        ldb   #3
        lsrb                   ; Divide by 10 (approximation of ×0.3)
        sta   parallax_offset_x
        jsr   RenderParallaxLayer
        
        ; Layer 1: Tilemap (normal camera offset)
        jsr   RenderLevel
        
        ; Layer 2: Foreground elements (parallax × 1.5)
        lda   camera_x
        ldb   #3
        mul                    ; Multiply by 1.5
        lsra
        sta   parallax_offset_x
        jsr   RenderForegroundLayer
        
        rts
```

---

## Common Mistakes

### Mistake 1: Camera Jitter

**The Problem**:
```asm
; WRONG: Camera updates every frame without smoothing
UpdateCamera:
        ; Jump camera directly to player
        lda   player_x
        sta   camera_x         ; Direct assignment
        lda   player_y
        sta   camera_y
        rts

; Result: Camera snaps frame-to-frame, creating jittery motion
```

**Why It Fails**:
- Player position fluctuates by 1–2 pixels frame-to-frame (physics simulation)
- Camera directly following causes visible jitter
- Smooth motion requires gradual interpolation, not direct assignment

**The Fix**:
```asm
; RIGHT: Smooth camera interpolation
UpdateCamera:
        ; Calculate target position
        lda   player_x
        suba  #160             ; Center on player
        sta   camera_target_x
        
        ; Interpolate toward target (max 3 pixels/frame)
        lda   camera_x
        cmpa  camera_target_x
        beq   .done
        blt   .move_right
        
        ; Move left (max 3 pixels)
        suba  #3
        cmp   camera_target_x  ; Don't overshoot
        bge   .update_x
        lda   camera_target_x
        
.update_x:
        sta   camera_x
        bra   .done
        
.move_right:
        adda  #3               ; Move right
        cmp   camera_target_x  ; Check for overshoot
        ble   .update_x
        lda   camera_target_x
        bra   .update_x
        
.done:
        rts
```

**Lesson**: Use interpolation (gradual movement) rather than direct assignment. Smooth camera motion improves perceived gameplay quality significantly.

---

### Mistake 2: Walking Through Walls

**The Problem**:
```asm
; WRONG: Collision detection only at player center
CanPlayerMoveTo:
        ; Check only center of player sprite
        jsr   GetTileID
        cmp   #128             ; Solid?
        bge   .blocked
        clra                   ; Passable
        rts
        
.blocked:
        lda   #1
        rts

; Player can squeeze into tight spaces and clip through walls
```

**Why It Fails**:
- Checking only center point misses wall collisions at edges
- Player sprite is typically 8×8 pixels; only checking center ignores half the sprite
- Creates exploitable gaps in collision detection

**The Fix**:
```asm
; RIGHT: Check all four corners
CanPlayerMoveTo:
        ; Assume X, Y = top-left corner of 8×8 sprite
        
        ; Check all four corners
        jsr   GetTileID
        cmp   #128
        bge   .blocked
        
        leax  7,x              ; Top-right
        jsr   GetTileID
        cmp   #128
        bge   .blocked
        
        leay  7,y              ; Bottom-right
        leax  7,x
        jsr   GetTileID
        cmp   #128
        bge   .blocked
        
        leax  -7,x             ; Bottom-left
        jsr   GetTileID
        cmp   #128
        bge   .blocked
        
        clra                   ; All corners clear
        rts
        
.blocked:
        lda   #1
        rts
```

**Lesson**: Check all four corners of player sprite bounding box, not just the center. Tile-based collision requires testing each corner.

---

### Mistake 3: Incorrect Viewport Tile Calculation

**The Problem**:
```asm
; WRONG: Treating camera position directly as tile offset
RenderLevel:
        lda   camera_x         ; 0–8000+ pixels
        sta   viewport_tile_x  ; Confused units!
        lda   camera_y
        sta   viewport_tile_y  ; Should be 0–50 tiles, not pixels
        
        ; Viewport calculation is completely wrong
        jsr   RenderTiles
        rts
```

**Why It Fails**:
- Camera position is in pixels (0–8000+)
- Viewport needs tile coordinates (0–40)
- Without division by 8, rendering accesses wrong tilemap indices
- Tiles render at completely wrong locations or crash due to out-of-bounds

**The Fix**:
```asm
; RIGHT: Convert pixel coordinates to tile indices
RenderLevel:
        ; Camera X is in pixels; divide by 8 for tile column
        lda   camera_x
        lsra
        lsra
        lsra                   ; Divide by 8
        sta   viewport_tile_x  ; Now in range 0–40
        
        ; Camera Y is in pixels; divide by 8 for tile row
        lda   camera_y
        lsra
        lsra
        lsra                   ; Divide by 8
        sta   viewport_tile_y  ; Now in range 0–32
        
        jsr   RenderTiles
        rts
```

**Lesson**: Always convert between pixel and tile coordinates. 1 tile = 8 pixels; use LSR (logical shift right) by 3 bits to divide by 8.

---

### Mistake 4: Rendering at Wrong Pixel Offsets

**The Problem**:
```asm
; WRONG: Tile pixel position calculated from camera directly
RenderTile:
        ; tile_index_x, tile_index_y in range 0–40
        ; But pixel rendering uses camera_x directly
        
        lda   camera_x         ; e.g., 150 pixels
        sta   screen_x         ; Tiles render at pixel 150!
        lda   camera_y
        sta   screen_y
        
        jsr   DrawTile         ; Tiles are offset incorrectly
        rts

; Tiles don't align to screen; rendering is distorted
```

**Why It Fails**:
- Tile pixel position = tile_index × 8 - (camera_x % 8)
- Using camera_x directly skips the sub-tile offset calculation
- Tiles don't align to 8-pixel boundaries on-screen

**The Fix**:
```asm
; RIGHT: Calculate pixel position with sub-tile offset
RenderTile:
        ; tile_index_x = 5 (5th tile column)
        ; camera_x = 150 pixels (offset into tile)
        
        ; Screen X = (tile_index_x × 8) - (camera_x % 8)
        lda   viewport_tile_x
        adda  tile_offset_x    ; Local tile column (0–40)
        lslb
        lslb
        lslb                   ; Multiply by 8 for pixels
        
        ; Subtract camera fractional offset
        lda   camera_x
        anda  #$07             ; Get lower 3 bits (0–7)
        suba  b
        sta   screen_x         ; Final pixel X
        
        ; Same for Y
        ; ...
        
        jsr   DrawTile
        rts
```

**Lesson**: Tile pixel position = (tile_index × 8) - (camera_position % 8). The modulo operation extracts the fractional tile offset.

---

### Mistake 5: Level Bounds Not Checked During Collision

**The Problem**:
```asm
; WRONG: No bounds checking in GetTileID
GetTileID:
        lda   temp_row
        ldb   level_width
        mul
        adda  temp_col
        
        ldx   level_data_ptr
        lda   a,x              ; Could read past tilemap end!
        rts

; Accessing out-of-bounds tilemap returns garbage; players walk through edges
```

**Why It Fails**:
- If player is near level edge, tilemap index exceeds level bounds
- Reads from ROM or other memory areas, causing unpredictable behavior
- Player can walk through the edge of the level into void

**The Fix**:
```asm
; RIGHT: Bounds check before tilemap access
GetTileID:
        ; Check if coordinates are within bounds
        lda   temp_row
        cmp   level_height
        bge   .out_of_bounds
        
        lda   temp_col
        cmp   level_width
        bge   .out_of_bounds
        
        ; Calculate index safely
        lda   temp_row
        ldb   level_width
        mul
        adda  temp_col
        
        ldx   level_data_ptr
        lda   a,x              ; Safe access
        rts
        
.out_of_bounds:
        lda   #255             ; Return solid (can't walk out of level)
        rts
```

**Lesson**: Always bounds-check before accessing tilemap. Return a solid tile (255) or passable (0) for out-of-bounds to prevent crashes.

---

## Real-World Usage

### R-Type Game Example

R-Type features horizontal scrolling levels with dynamic camera control:

```asm
; From game-projects/r-type/levels/LevelManager.asm

LoadRTypeLevel:
        lda   current_level    ; Level 1–8
        jsr   LoadLevel        ; Load tilemap and graphics
        
        ; R-Type uses side-scrolling: camera follows player horizontally
        ; Player can move vertically but level scrolls left-right
        rts

UpdateRTypeCamera:
        ; Horizontal scroll: camera tracks player X (auto-scroll)
        ; Vertical: limited to viewport height (no vertical scroll)
        
        lda   player_x         ; Player moving right
        suba  #80              ; Offset so player is 1/4 across screen
        sta   camera_target_x
        
        ; Vertical: keep player centered but within level
        lda   player_y
        suba  #112             ; Center on player
        jsr   UpdateCamera
        rts

RenderRTypeFrame:
        jsr   UpdateCamera
        jsr   RenderLevel      ; Horizontal scrolling tilemap
        
        ; Render enemies and bullets in front of level
        jsr   RenderEnemies
        jsr   RenderProjectiles
        jsr   RenderPlayer     ; Player on top
        rts
```

R-Type levels demonstrate aggressive horizontal scrolling:

```asm
; Player at position 1000 pixels into 4000-pixel level
; Camera X = 920 (always 80 pixels ahead of player)
; Visible viewport: tiles 115–120 (pixels 920–1240)
; Players can't move backward (no camera pan left)
```

### Goldorak Game Example

Goldorak features free-roaming exploration with centered camera:

```asm
; From goldorak/levels/ExplorationMode.asm

LoadGoldorakLevel:
        lda   selected_level
        jsr   LoadLevel        ; Load full level
        rts

UpdateGoldorakCamera:
        ; Goldorak: free 360-degree camera movement
        ; Camera centered on player in middle of screen
        
        jsr   UpdateCamera     ; Smooth interpolation toward player
        
        ; Clamp to level bounds (prevents black void at edges)
        jsr   UpdateCameraBounded
        rts

GoldorakGameLoop:
        jsr   ReadInput
        jsr   UpdatePlayerMovement   ; Player moves freely
        jsr   UpdateEnemies
        jsr   UpdateCamera
        
        jsr   WaitVBL
        jsr   RenderLevel             ; Draw tilemap
        jsr   RenderParallaxBackgrounds
        jsr   RenderEnemies
        jsr   RenderPlayer            ; Goldorak sprite
        jsr   RenderUI
        bra   GoldorakGameLoop
```

### Parallax Scrolling Example

Multi-layer scrolling at different speeds (depth effect):

```asm
; From tutorial/templates/level-parallax/

RenderWithParallax:
        ; Background layer (clouds): scrolls at 0.3× camera speed
        lda   camera_x
        ldb   #3
        lsrb                   ; Approximate 0.3× by dividing by 10
        sta   parallax_offset_x
        jsr   RenderSkyLayer
        
        ; Mid-ground: tilemap (1.0× camera speed)
        jsr   RenderLevel
        
        ; Foreground (trees): 1.5× camera speed (closer, moves faster)
        lda   camera_x
        ldb   #3
        mul                    ; Multiply by 1.5
        lsra
        sta   parallax_offset_x
        jsr   RenderForegroundLayer
        
        ; Sprites (enemies, player) on top
        jsr   RenderSprites
        rts
```

---

## Further Reading

**Related API References**:
- **Object Management** — Enemy and pickup spawning within levels
- **Collision Detection** — Detailed collision response and callbacks
- **Graphics Subsystem** — Tile rendering and video memory layout

**Engine Source Code**:
- `/engine/levels/loading/LoadLevel.asm` — Level disk I/O
- `/engine/levels/rendering/RenderTilemap.asm` — Tilemap rendering
- `/engine/levels/camera/UpdateCamera.asm` — Camera logic
- `/engine/levels/collision/GetTileID.asm` — Fast tile lookup

**Tutorial References**:
- `tutorial/getting-started/03-level-system.md` — Loading and rendering levels
- `tutorial/extending/03-camera-control.md` — Camera patterns
- `tutorial/patterns/parallax-scrolling.md` — Multi-layer scrolling

---

**End of Level Management API Reference**

Generated: June 2026  
Quality Level: Production-Ready
