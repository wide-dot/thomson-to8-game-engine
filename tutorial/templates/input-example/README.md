# Joypad Input Example

Minimal code showing how to read player input from the joypad.

## What This Does

- Reads the joypad state from the PIA port
- Detects button presses (rising edges)
- Handles direction input (up, down, left, right)
- Provides debounced input state

## How to Adapt

1. **Implement movement handlers**:
   ```asm
   MoveUp:
       ; Move player up by 1 pixel
       lda PlayerY
       deca
       sta PlayerY
       rts
   ```

2. **Handle button actions**:
   ```asm
   ButtonPressed:
       ; Fire a projectile or jump
       jsr SpawnProjectile
       rts
   ```

3. **Add more buttons**:
   - Button 1 (Fire): Bit 4
   - Button 2 (Special): Bit 5

## Input Bits

The joypad port (PIA_PORTB at $E7CB) returns:
- Bit 0: UP (0 = pressed)
- Bit 1: DOWN (0 = pressed)
- Bit 2: LEFT (0 = pressed)
- Bit 3: RIGHT (0 = pressed)
- Bit 4: BUTTON1/FIRE (0 = pressed)
- Bit 5: BUTTON2 (0 = pressed)

## Usage Pattern

```asm
jsr ReadJoypad          ; Get current input
jsr CheckInputs         ; Check for changes
```

Each frame:
1. Read joypad port
2. Compare with previous frame
3. Detect button transitions
4. Handle actions accordingly

## Using This Example

### Build
```bash
cd tutorial/templates/input-example
togen build.properties
```

### Run
```bash
to8 dist/input.fd
```

## What Happens

Press joypad buttons and watch the handler functions get called.

## Real-World Example

See `game-projects/goldorak/` for complete input handling with:
- Smooth movement
- Animation switching
- Multi-button combinations

## Related Documentation

- `tutorial/api-reference/joypad-subsystem.md` — Full joypad API
- `tutorial/templates/sprite-example/` — Drawing sprites
- `tutorial/templates/collision-example/` — Detecting collisions
