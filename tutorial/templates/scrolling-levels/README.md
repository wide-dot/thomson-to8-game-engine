# Scrolling Levels Example

Minimal code showing how to implement tile-based level rendering with camera scrolling.

## What This Does

- Defines a simple tile-based level map
- Implements camera/viewport positioning
- Renders only visible tiles to the screen
- Scrolls the viewport to follow the player

## How to Adapt

1. **Replace the tilemap**:
   ```asm
   TileMap:
       ; Row 0: 20 tiles (1 = solid wall, 0 = empty)
       fcb 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
       ; Row 1
       fcb 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
       ; ...more rows
   ```

2. **Customize camera behavior**:
   ```asm
   UpdateCamera:
       ; Make camera lag behind player
       ldd CameraX
       lde PlayerX
       sube #SCREEN_WIDTH / 2
       ; Lerp: CameraX = CameraX + (TargetX - CameraX) / 8
   ```

3. **Add tile graphics**:
   - Replace `RenderLevel` with actual blitting code
   - Use `GetTile` to look up tile type
   - Fetch tile graphics and blit to screen

4. **Implement collision**:
   ```asm
   ; Check if next position collides with solid tiles
   lda GetTile(newX / TILE_SIZE, newY / TILE_SIZE)
   cmpa #1         ; Is it solid?
   beq Collision
   ```

## Tilemap Format

```
TileMap:
    fcb tile0, tile1, tile2, ...   (20 tiles per row)
    fcb ...                        (15 rows total)
```

Each byte represents one tile (16x16 pixels):
- 0 = Empty (walkable)
- 1 = Solid wall (blocked)
- 2+ = Custom tile types (lava, spike, etc.)

## Coordinate Systems

### World Coordinates (Level)
```
(0,0) is top-left of entire level
Level size = MAP_WIDTH * TILE_SIZE = 320 pixels wide
           = MAP_HEIGHT * TILE_SIZE = 240 pixels tall
```

### Screen Coordinates (Viewport)
```
(0,0) is top-left of visible screen
Screen size = 320x200 pixels
```

### Tile Coordinates
```
TileX = PixelX / TILE_SIZE
TileY = PixelY / TILE_SIZE
```

## Using This Example

### Build
```bash
cd tutorial/templates/scrolling-levels
togen build.properties
```

### Run
```bash
to8 dist/scrolling.fd
```

## What Happens

- Camera follows player around the level
- Only visible tiles are rendered
- Tiles scroll smoothly as player moves

## Optimization Tips

### Dirty Rectangle Optimization
Only redraw tiles that have changed (moved into viewport).

### Chunking
Divide level into chunks, only render visible chunks.

### Tile Caching
Pre-compute blitted tile graphics to speed up rendering.

### Culling
Skip rendering tiles outside the viewport entirely.

## Real-World Example

See `game-projects/goldorak/` for production level handling with:
- Multiple tile layers (background, platform, decoration)
- Parallax scrolling
- Dynamic tile updates (doors opening, etc.)
- Collision maps separate from render maps

## Related Documentation

- `tutorial/api-reference/level-management.md` — Full level API
- `tutorial/templates/sprite-example/` — Rendering sprites
- `tutorial/templates/collision-example/` — Platform collision
