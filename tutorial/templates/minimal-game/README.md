# Minimal Game Template

This is the **starter scaffold** for Thomson TO8 games. It provides the complete directory structure and configuration needed to build a game using the engine.

## What This Is

A minimal, runnable game project that compiles to a bootable floppy disk (or cartridge). Use this as your starting point for any new game.

## Directory Structure

```
minimal-game/
├── game-mode/         # Game screens (title, gameplay, game-over, etc.)
├── objects/           # Game object definitions (player, enemies, items)
├── global/            # Shared constants, macros, and variables
├── resources/         # Sprite sheets and tile maps
├── cfg/               # Audio and music configuration
├── dist/              # Build output (floppy, cartridge, SD card)
└── config-*.properties # Build configuration for Linux/macOS/Windows
```

## How to Use This Template

### 1. Copy This Folder
```bash
cp -r tutorial/templates/minimal-game game-projects/my-game
cd game-projects/my-game
```

### 2. Edit Your Game Objects
Modify `objects/` to define:
- Player sprite and input handling
- Enemy types and AI
- Projectiles
- Collectible items

**Example**: See `tutorial/templates/sprite-example/` for a minimal sprite blitting example.

### 3. Create Game Modes
Modify `game-mode/` to define:
- Title/splash screen
- Main gameplay loop
- Pause menu
- Game over screen

### 4. Add Graphics
Replace files in `resources/`:
- `sprites.png` — Object sprites (16x16, 32x32, etc.)
- `tiles.png` — Background tileset

### 5. Configure Audio
Edit `music.xml` to include your music tracks.

### 6. Build and Run

**Linux:**
```bash
togen ./config-linux.properties
to8 dist/my-game.fd
```

**macOS:**
```bash
togen ./config-macos.properties
to8 dist/my-game.fd
```

**Windows:**
```bash
togen ./config-windows.properties
to8 dist\my-game.fd
```

## What to Change

Look for **CHANGE THIS** comments in the code:
- `game-mode/main.asm` — Your gameplay loop
- `objects/player.asm` — Your player character
- `music.xml` — Your game's music
- `resources/` — Your graphics

## Engine Subsystems Used

This template uses:
- **Boot** — Initialize hardware
- **Graphics** — Render sprites and tiles
- **Joypad** — Read player input
- **Object Management** — Spawn/update/destroy objects
- **Collision** — Detect collisions between objects
- **Sound** — Play music and SFX
- **Level Management** — Load and manage level data

## Next Steps

1. **Read the tutorial**: See `tutorial/getting-started/` for step-by-step guides
2. **API Reference**: Check `tutorial/api-reference/` for subsystem details
3. **Code Examples**: Look at `tutorial/templates/sprite-example/`, `input-example/`, etc.
4. **Real Games**: Study `game-projects/goldorak/` or `game-projects/r-type/`

## Output Files

After building, you get three versions:
- `dist/my-game.fd` — Floppy disk image (for Theodore emulator)
- `dist/my-game.rom` — Cartridge ROM image
- `dist/my-game.sd` — SD card image (for hardware)

## Common Customizations

### Change Game Resolution
Edit `to8.config.xml`:
```xml
<screen width="320" height="200" mode="16-color"/>
```

### Add a Second Joypad
Edit `global/input.asm` to read both joystick 1 and joystick 2.

### Increase Sprite Limit
Edit `objects/config.asm` to increase the max object count.

### Add a Custom Font
Place your font in `resources/font.png` and load it in `game-mode/title.asm`.

## Troubleshooting

**Build fails:**
- Ensure `togen` is installed and in PATH
- Check `config-*.properties` points to correct paths

**Game won't start:**
- Check boot code in `game-mode/main.asm`
- Verify interrupt handlers are set up

**Graphics glitchy:**
- Check sprite coordinates and palette
- Verify tile maps are in correct format

**Sound not playing:**
- Check `music.xml` syntax
- Verify audio files exist in `cfg/`

## Reference

- **Engine Subsystems**: `tutorial/api-reference/`
- **Code Examples**: `tutorial/templates/`
- **Real Games**: `game-projects/goldorak/`, `game-projects/r-type/`
- **Getting Started**: `tutorial/getting-started/`
