# Tutorial Structure & Navigation

This document explains how the tutorial is organized and which section to use when.

## Three Main Sections

### Getting Started (`getting-started/`)

**What it covers**: Steps 00-03, foundational game development

- Step 00: Boot & initialization
- Step 01: Graphics fundamentals
- Step 02: Input handling (joypad)
- Step 03: Object management basics

**When to use**: 
- You're new to Thomson TO8 game development
- You need a working game framework before tackling advanced features
- You're learning the engine for the first time

**What you'll build**: A minimal working game that responds to input and displays graphics.

---

### Extending (`extending/`)

**What it covers**: Steps 04-07, advanced game features

- Step 04: Collision detection
- Step 05: Sound & music
- Step 06: Level management
- Step 07: Palette & effects

**When to use**:
- You've completed Getting Started steps 00-03
- You want to add complexity (collision, audio, levels)
- You're extending an existing game with new features

**What you'll build**: A complete game with audio, levels, and collision mechanics.

---

### API Reference (`api-reference/`)

**What it covers**: Deep technical documentation per subsystem

- Graphics API
- Joypad API
- Collision API
- Sound API
- Level Management API
- Object Management API
- Palette API
- Boot API

**When to use**:
- You need detailed API documentation while coding
- You want to understand subsystem internals
- You need reference material for a specific function/feature

**What you'll find**: Function signatures, parameters, return values, examples, hardware constraints, optimization tips.

---

## Relationship to Other Documentation

**`/docs/readme.md`** (Project Architecture)
- Theory and architecture of the engine
- System design decisions
- How subsystems fit together

**`/tutorial/README.md`** (Entry Point)
- Navigation hub
- Learning paths
- Quick reference to all sections

**`/tutorial/getting-started/` + `/tutorial/extending/`** (Hands-On Learning)
- Step-by-step tutorials
- Code examples for each step
- Practical exercises

**`/tutorial/api-reference/`** (Reference Material)
- Technical API documentation
- Function definitions
- Implementation details

---

## Code Templates (`templates/`)

Ready-to-use project scaffolds:

- **Minimal Game Template**: Bare bones starting point
- **Sprite-Based Game Template**: For sprite-heavy games
- **Tile-Based Game Template**: For tile map games
- **State Machine Template**: Entity state management
- **Collision Template**: Collision system setup
- **Audio Template**: Sound/music initialization

**When to use**: Start a new game project by copying and modifying the appropriate template.

---

## Reading Flow

### For Beginners
1. Read `README.md` (this file) to understand structure
2. Choose a learning path in `README.md`
3. Work through Getting Started (steps 00-03)
4. Refer to API Reference as needed
5. Use a code template to scaffold your project

### For Experienced Developers
1. Skim `README.md` for overview
2. Choose Path B (Extending) or Path C (Deep Knowledge)
3. Jump to Extending (steps 04-07)
4. Reference API docs for unfamiliar subsystems

### For Reference/Lookup
1. Go to `README.md`
2. Find your subsystem in API Reference section
3. Open the corresponding file in `api-reference/`

---

## File Organization

```
tutorial/
├── README.md              # Main entry point and navigation
├── STRUCTURE.md          # This file - explains the structure
├── getting-started/      # Steps 00-03
│   ├── step-00-boot.md
│   ├── step-01-graphics.md
│   ├── step-02-joypad.md
│   └── step-03-objects.md
├── extending/            # Steps 04-07
│   ├── step-04-collision.md
│   ├── step-05-sound.md
│   ├── step-06-levels.md
│   └── step-07-palette.md
├── api-reference/        # API documentation
│   ├── graphics-api.md
│   ├── joypad-api.md
│   ├── collision-api.md
│   ├── sound-api.md
│   ├── level-management-api.md
│   ├── object-management-api.md
│   ├── palette-api.md
│   └── boot-api.md
└── templates/            # Code templates
    ├── minimal-game.asm
    ├── sprite-game.asm
    ├── tile-game.asm
    ├── state-machine.asm
    ├── collision.asm
    └── audio.asm
```

---

## Tips

- **Lost?** Start at `README.md` and pick a learning path
- **Need API docs?** Go to `api-reference/` and search for your subsystem
- **Want to scaffold?** Use a template from `templates/`
- **Want theory?** See `/docs/readme.md` for architecture
- **Want examples?** See `/game-projects/` for complete games

