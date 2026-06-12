# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Goldorak is a game for the Thomson TO8 computer (1986 French home computer), written in 6809 assembly language. It uses a Java-based build generator to compile sprites, animations, and music into multiple output formats (floppy disk `.fd`, ROM cartridge `.rom`, SD card `.sd`).

## Build & Compile

### Quick Reference
- **Build**: `togen ./config-linux.properties` (from goldorak directory)
- **Run**: `to8 dist/goldorak.fd` (launches RetroArch emulator)
- **Clean**: `./clean` (removes generated files)

### Prerequisites
- Java 11+ (verify with `java -version`)
- Maven 3.6.x+ (verify with `mvn -version`)
- Linux `lwasm` assembler (pre-installed in `tools/linux/lwasm`)
- RetroArch with Theodore TO8 core (for `to8` emulator launcher)

### Building the Java Generator
From the engine root directory:
```bash
cd java-generator
mvn clean compile assembly:single
```
Output: `java-generator/target/game-engine-0.0.1-SNAPSHOT-jar-with-dependencies.jar`

### Building the Game
From the goldorak directory, use the `togen` shortcut:
```bash
togen ./config-linux.properties
```

Or manually:
```bash
java -jar ../../java-generator/target/game-engine-0.0.1-SNAPSHOT-jar-with-dependencies.jar ./config-linux.properties
```

For other systems:
- macOS: `config-macos.properties`
- Windows: `config-windows.properties`

Output files in `dist/`:
- `goldorak.fd` — floppy disk image
- `goldorak.rom` — ROM cartridge
- `goldorak.sd` — SD card format

### Running the Game
After build, test in RetroArch emulator (Theodore TO8 core):
```bash
to8 dist/goldorak.fd
```
(or `.rom` / `.sd` depending on output format)

### Cleaning Generated Files
```bash
./clean
```
Removes: `generated-code/`, `logs/`, `dist/`

## Project Structure

### Core Directories

**`game-mode/`** — Game screens/modes
- `gamescreen/` — Main game screen (entry point)
- `splash/` — Splash screen
- `loading/` — Loading screen

**`objects/`** — Reusable sprites, animations, and audio
- `goldorak/` — Main character sprites and animations
- `weapons/` — Weapon definitions
- `cockpit/` — HUD/cockpit UI
- `scroll/` — Scrolling background level data
- `music/` — Music definitions
- `levels/` — Level configuration
- `vignettes/` — Intro/outro scenes

**`global/`** — Shared definitions (accessible to all modes and objects)
- `global-equates.asm` — Named constants
- `global-macros.asm` — Reusable assembly macros
- `global-variables.asm` — Shared memory variables
- `global-*-includes.asm` — Preamble/trailer includes for compilation

**`resources/`** — Generic graphics library (sprites, fonts, UI elements)

**`generated-code/`** — Auto-generated during build (sprites as ASM, compiled lists, constants)

### Configuration Files

**`config-[os].properties`** — Build configuration per platform, specifying:
- Engine components (bootloader, RAM loader)
- Game mode entry point and assets
- Build parameters (lwasm options, optimization settings, parallelization)
- Output file paths

## Architecture

### Compilation Flow
1. Java generator parses the config properties file
2. For each game mode and object:
   - Reads `.properties` file (defines sprites, palettes, animations)
   - Reads/converts image files (PNG → palette + sprite ASM)
   - Compiles `.asm` files using lwasm
   - Optimizes compiled sprite code (iterative random tries up to max iterations)
   - Generates `.equ` constants and `.lst` listing files
3. Links all ASM modules together into final binary
4. Outputs in multiple formats (floppy, ROM, SD)

### Game Mode Entry Point
The entry point is defined by `gameModeBoot` in the config file (currently `gamescreen`). The main game loop:
- Initializes Goldorak sprite and animation state
- Renders cockpit (HUD)
- Runs level scrolling with collision detection
- Handles weapon firing and sprite animation
- Updates palette and music

### Memory Model
- TO8 has 64KB base RAM + optional extended RAM
- Extended RAM enabled via `builder.to8.memoryExtension=Y`
- Engine uses RAM loaders to decompress code (zx0 compression)
- Sprite data and animation tables resident in memory

### Key Compiler Directives (lwasm)
- `pragma undefextern` — Allow undefined external symbols (handled during linking)
- `define` — Preprocessor macros passed from config (e.g., boot colors)
- `includeDirs` — Assembly include path resolution

## Development Workflow

### Modifying Existing Game Modes
Edit `.asm` files in `game-mode/[mode-name]/` and recompile:
```bash
togen ./config-linux.properties
```
The Java generator recompiles incrementally; use `builder.compilatedSprite.useCache=Y` to cache.

Test in emulator:
```bash
to8 dist/goldorak.fd
```

### Adding Sprites & Animations
1. Create a PNG image with palette
2. Create an `.asm` file defining animation frames and offsets
3. Create a `.properties` file referencing the image and ASM
4. Reference in the relevant game mode's `.properties` file under `object.YourObject=./path/obj.properties`
5. Rebuild

### Adding New Objects
1. Create directory under `objects/[type]/[name]/`
2. Add image, `.asm`, and `.properties` files
3. Reference in a game mode's `.properties` file
4. Rebuild

### Modifying Global Definitions
Edit files in `global/`:
- **Equates** (`global-equates.asm`): Memory addresses, screen constants, color indices
- **Macros** (`global-macros.asm`): Reusable instruction sequences (sprite rendering, collision checks)
- **Variables** (`global-variables.asm`): Shared memory state

Changes automatically propagate to all game modes and objects on rebuild.

## Debugging & Optimization

### Build Parameters
Key settings in config file:
- `builder.debug=Y` — Enable debug symbols in compiled ASM
- `builder.logToConsole=Y` — Print build output to console
- `builder.parallel=Y` — Parallel sprite compilation (faster)
- `builder.compilatedSprite.useCache=Y` — Cache sprite compilation results (faster rebuilds)
- `builder.compilatedSprite.maxTries=500000` — Iterations for code optimization (higher = slower but better code)

### Generated Files
After build, check `generated-code/` for:
- `*.lst` — Assembler listing files (instructions, addresses, symbols)
- `*.equ` — Constants and equate definitions
- `.asm` — Generated sprite code (study generated patterns)
- `.bin` — Binary sprite data (for debugging in hex editor)

### Logs
- `logs/` directory contains detailed build logs per mode/object

## Key Files & Patterns

### Game Mode Template
`game-mode/gamescreen/main.asm` — Entry point that:
- Sets up graphics mode and palette
- Initializes sprite and animation structures
- Runs main game loop

### Object Template
`objects/goldorak/goldorak.properties` — References:
- Sprite images
- Animation frame definitions
- Palette usage
- Collision/hitbox data

### Palette Management
Palettes are PNG files with standard Thomson TO8 color palette (256 colors). All sprites must share or explicitly define their palette.

## Music & Audio
Music is defined in `.properties` files pointing to music object definitions. The engine supports:
- Tracker-based music (compiled from `.xml` or tracker format)
- SFX playback

See `objects/music/goldorak/` for music definitions.

## Performance Notes
- Sprite compilation with optimization can take several minutes (parallel build helps)
- Cache settings (`useCache=Y`) significantly speed up rebuilds during development
- Increase `maxTries` for final release builds, decrease for fast iteration
- Monitor `logs/` for compilation bottlenecks
