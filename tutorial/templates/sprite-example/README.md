# Sprite Blitting Example

Minimal code showing how to define and blit a 16x16 sprite to the screen.

## What This Does

- Defines a simple 16x16 sprite in memory
- Blits it to two positions on screen
- Shows the basic structure of sprite rendering

## How to Adapt

1. **Replace the sprite data** in `sprite.asm`:
   ```asm
   SpriteData:
       fcb $FF, $FF    ; Replace these bytes with your sprite
       fcb $FF, $FF
       ...
   ```

2. **Change blitting positions**:
   ```asm
   lda #10         ; Change X position
   ldx #10         ; Change Y position
   jsr BlitSprite
   ```

3. **Add actual blitting logic** in the `BlitSprite` routine:
   - The current code is a stub
   - You need to copy sprite bytes to VRAM
   - Handle transparency/masking if needed

## Sprite Format

- **Size**: 16x16 pixels
- **Color Mode**: 16 colors
- **Memory Layout**: 2 bytes per line (16 pixels = 8 pixels per byte in 16-color mode)
- **Total Size**: 32 bytes (2 bytes × 16 lines)

## Pixel Encoding in 16-Color Mode

Each byte represents 2 pixels (4 bits each):
```
Byte:   0xAB
Pixel 1: 0xA (left pixel)
Pixel 2: 0xB (right pixel)
```

For example:
- `0xFF` = two white pixels (color 15, color 15)
- `0xF0` = white pixel + black pixel (color 15, color 0)
- `0x00` = two black pixels (color 0, color 0)

## Using This Example

### Build
```bash
cd tutorial/templates/sprite-example
togen build.properties
```

### Run
```bash
to8 dist/sprite.fd
```

## What Happens

The example blits a simple square sprite at two positions on the screen.

## Next Steps

1. **Customize the sprite** — Edit the byte values to create your own pattern
2. **Add multiple sprites** — Copy the `jsr BlitSprite` call multiple times
3. **Animate sprites** — Use a loop to change the position and redraw each frame
4. **Use real graphics** — Replace the hardcoded bytes with data from a sprite sheet

## Real-World Example

See `game-projects/goldorak/objects/` for complete sprite definitions and blitting code.

## Related Documentation

- `tutorial/api-reference/graphics-subsystem.md` — Full graphics API
- `tutorial/templates/input-example/` — Reading joypad input
- `tutorial/templates/collision-example/` — Detecting collisions
