# Code Examples

Reference implementations extracted from r-type game, showing how to use each engine subsystem.

## Navigation by Subsystem

Each subsystem has example .asm files showing practical usage:

- **graphics/** — Sprite rendering, tilemap setup, palette
  - `sprite-blitting.asm` — Render sprites to screen

- **collision/** — Collision detection and hitbox management
  - `collision-detection.asm` — AABB collision between objects

- **joypad/** — Joystick and gamepad input
  - `input-polling.asm` — Read joystick each frame

- **sound/** — Music and sound effects
  - `music-init.asm` — Load and play background music

- **object-management/** — Spawning and managing game objects
  - `spawning.asm` — Spawn enemies, run update loop

- **level-management/** — Loading levels and scrolling
  - `level-loading.asm` — Load level data

- **irq/** — Interrupt handling
  - `interrupt-handling.asm` — Register and handle interrupts

- **keyboard/** — Keyboard input
  - `keyboard-input.asm` — Read keyboard events

- **math/** — Mathematical utilities
  - `fixed-point-math.asm` — Multiply, divide, trig functions

## How to Use These Examples

1. Find the subsystem you need in `../engine-subsystems.md`
2. Browse its example folder: `doc/examples/[subsystem]/`
3. Copy the snippet code into your game
4. Adapt variable names and register assignments for your game
5. Reference the "See full context" comment to understand the full r-type implementation

## Example Workflow

Adding player input to your game:

1. Read `../engine-subsystems.md` → "joypad" subsystem
2. Open `joypad/input-polling.asm`
3. Copy the `poll-player-input` function into your game
4. Modify `player:move-up`, `player:move-down`, etc. for your player object
5. Call `poll-player-input` once per frame in your main game loop

## Reference

- **Engine subsystems catalog:** `../engine-subsystems.md`
- **Game template:** `../../templates/new-game-template/`
- **Example games:** `../../game-projects/r-type/`, `../../game-projects/test/`
