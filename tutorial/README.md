# Thomson TO8 Game Engine Tutorial

Welcome to the Thomson TO8 game engine tutorial. This guide walks you through building games from bootloader to complete game logic using 8 core subsystems.

## Quick Start

Build your first game in steps:

- **Step 00**: Boot & initialization
- **Step 01**: Graphics fundamentals
- **Step 02**: Input handling (joypad)
- **Step 03**: Object management basics
- **Step 04**: Collision detection
- **Step 05**: Sound & music
- **Step 06**: Level management
- **Step 07**: Palette & effects

## Learning Paths

Choose your path based on your goals:

### Path A: I Want a Game ASAP
For developers who want working code fast.

1. Read Getting Started (Step 00 through Step 03)
2. Use the **Minimal Game Template** to scaffold your project
3. Reference API docs as needed for each subsystem

**Time**: 2-3 hours

### Path B: I'm Extending an Existing Game
For developers building on top of the engine.

1. Review Getting Started (quick brush-up on steps 00-03)
2. Focus on Extending section (Step 04 through Step 07)
3. Deep-dive API Reference for subsystems you're working with

**Time**: 1-2 hours

### Path C: I Want Deep Knowledge
For developers who need to understand every detail.

1. Work through Getting Started (Step 00 through Step 03)
2. Work through Extending (Step 04 through Step 07)
3. Read entire API Reference for each subsystem
4. Study code templates and examples

**Time**: 4-5 hours

## Section Guides

### Getting Started

Foundational steps to build your first working game. Covers boot, graphics, input, and basic object management.

- **Step 00**: Boot & initialization
- **Step 01**: Graphics fundamentals
- **Step 02**: Input handling (joypad)
- **Step 03**: Object management basics

### Extending

Advanced features to add depth to your game. Covers collision, sound, levels, and effects.

- **Step 04**: Collision detection
- **Step 05**: Sound & music
- **Step 06**: Level management
- **Step 07**: Palette & effects

### API Reference

Deep technical documentation for each subsystem. Use as reference while coding.

- **Graphics API**: Display modes, sprites, bitmap operations, screen management
- **Joypad API**: Button input, debouncing, polling patterns
- **Collision API**: Bounding boxes, collision masks, response callbacks
- **Sound API**: Envelope control, PCM samples, music sequencing
- **Level Management API**: Tile maps, layer rendering, dynamic loading
- **Object Management API**: Entity lifecycle, state machines, pooling
- **Palette API**: Color tables, transitions, effects, mode switching
- **Boot API**: Memory setup, ROM detection, initialization sequences

## Code Templates

Ready-to-use scaffolds for common patterns:

- **Minimal Game Template**: Bare-bones game structure with all core systems
- **Sprite-Based Game Template**: Optimized for sprite-heavy games
- **Tile-Based Game Template**: Optimized for tile maps and levels
- **State Machine Template**: Entity state management framework
- **Collision Template**: Collision detection setup and callbacks
- **Audio Template**: Sound/music system initialization

## Resources

- **Project Documentation**: See `/docs/readme.md` for architecture and theory
- **Code Examples**: See `game-projects/` for complete example games
- **Hardware Reference**: Thomson TO8 hardware docs (linked in API Reference)

## Next Steps

1. Choose your learning path above
2. Start with Step 00 in Getting Started
3. Reference API docs as needed
4. Use code templates to scaffold
5. Build your game!

Have questions? Refer to STRUCTURE.md for orientation, or jump to the API Reference section for your specific subsystem.
