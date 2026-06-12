# New Game Template

Minimal scaffold for Thomson TO8 games using the engine.

## Quick Start

1. Copy this folder to `game-projects/my-game/`
2. Edit game objects in `objects/` and game modes in `game-mode/`
3. Update `music.xml` with your game music
4. Build: `togen ./config-linux.properties` (from this directory)
5. Run: `to8 dist/my-game.fd`

## Structure

- `game-mode/` — Game screens and modes (entry points for different screens)
- `objects/` — Game objects (player, enemies, projectiles, items)
- `global/` — Shared constants, macros, variables
- `resources/` — Sprite sheets, tile maps
- `cfg/` — Audio/music configuration
- `dist/` — Build output (floppy disk, cartridge, SD card images)

## Subsystems Used

This template uses these engine subsystems (see `../../doc/engine-subsystems.md`):
- **graphics** — Render sprites and tiles
- **joypad** — Read player input
- **object-management** — Spawn, update, destroy game objects
- **collision** — Detect hitbox collisions
- **sound** — Play music and sound effects
- **level-management** — Load and manage levels

## Customization

### 1. Modify Game Objects
Edit `objects/` to define your game objects:
- Player sprite and logic
- Enemy types
- Projectiles
- Items/collectibles

Reference: `../../doc/examples/object-management/spawning.asm`

### 2. Create Game Modes
Edit `game-mode/` to define game screens:
- Splash/title screen
- Main gameplay
- Pause menu
- Game over screen

### 3. Add Graphics
Edit `resources/` with your sprite sheets and tile maps:
- `resources/sprites.png` — Object sprites
- `resources/tiles.png` — Background tiles

### 4. Configure Audio
Edit `music.xml` to include your game music:
- Reference format from r-type game

### 5. Adjust Collision
Edit object files to define hitboxes using collision subsystem.

Reference: `../../doc/examples/collision/collision-detection.asm`

## Building

### Linux
```bash
togen ./config-linux.properties
```

### macOS
```bash
togen ./config-macos.properties
```

### Windows
```bash
togen ./config-windows.properties
```

Output files: `dist/my-game.fd`, `dist/my-game.rom`, `dist/my-game.sd`

## Running

```bash
to8 dist/my-game.fd
```

This launches RetroArch with Theodore TO8 core.

## Reference

- **Engine subsystems:** `../../doc/engine-subsystems.md`
- **Code examples:** `../../doc/examples/`
- **Example games:** `../../game-projects/r-type/`, `../../game-projects/test/`
