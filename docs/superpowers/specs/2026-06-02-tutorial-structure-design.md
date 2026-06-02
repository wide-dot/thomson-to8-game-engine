# Tutorial Structure Design — Thomson TO8 Game Engine

**Date:** 2026-06-02  
**Status:** Design approved by user  
**Scope:** Complete tutorial and API reference documentation for engine subsystems

---

## Problem Statement

Current documentation is fragmented and incomplete:
- doc/readme.md: educational chapters (many "à rédiger")
- doc/engine-subsystems.md: auto-generated subsystem catalog
- doc/examples/: scattered code snippets
- No guided path for developers building new games

**Pain points identified:**
1. Unclear which subsystems to use and in what order
2. No clear boilerplate or game structure to start with
3. Hard to understand how to use specific subsystems without examples

---

## Solution: Linear Learning + Reference Structure

**Two complementary resources:**
1. **Tutorial** (getting-started + extending): Step-by-step workflow for building a game, discovering subsystems in dependency order
2. **API Reference** (api-reference/): Deep dive per subsystem with complete API, patterns, gotchas, real-world usage

**Format:** Markdown + linked code templates (copy-paste starting points)

**Audience:** Game developers building new games; also serves as quick reference

---

## Directory Structure

```
tutorial/
├── README.md                          # Navigation index, learning paths
├── getting-started/
│   ├── 00-minimal-game.md            # Full walkthrough: build a playable game
│   ├── 01-sprite-system.md           # Add sprites to the game
│   ├── 02-input-handling.md          # Read joypad input
│   └── 03-collision-detection.md     # Detect sprite collisions
├── extending/
│   ├── 04-sound-and-music.md         # Add sound effects and music
│   ├── 05-level-scrolling.md         # Implement scrolling levels
│   ├── 06-advanced-collision.md      # Complex collision scenarios
│   └── 07-game-patterns.md           # Common game architecture patterns
├── api-reference/
│   ├── graphics-subsystem.md         # Complete graphics API reference
│   ├── joypad-subsystem.md           # Input API reference
│   ├── collision-subsystem.md        # Collision detection API
│   ├── sound-subsystem.md            # Sound/music API
│   ├── level-management.md           # Level/scrolling API
│   ├── object-management.md          # Game object lifecycle API
│   ├── palette-subsystem.md          # Palette/color API
│   ├── ram-subsystem.md              # Memory layout reference
│   ├── irq-subsystem.md              # Interrupt handling reference
│   └── boot-subsystem.md             # Initialization/boot reference
├── templates/
│   ├── minimal-game/                 # Starter game (referenced by 00-minimal-game.md)
│   ├── sprite-example/               # Minimal sprite usage (referenced by 01-sprite-system.md)
│   ├── input-example/                # Minimal input handling
│   ├── collision-example/            # Minimal collision demo
│   ├── scrolling-levels/             # Minimal scrolling level
│   └── sound-example/                # Minimal sound/music setup
└── STRUCTURE.md                       # Meta: explains the tutorial organization
```

---

## Content Format

### Tutorial Steps (getting-started/ & extending/)

Each markdown file follows this pattern:

1. **Objective** — What you'll build by end of this step
2. **Subsystems involved** — List each subsystem in activation order, with brief "why"
3. **Walkthrough** — Narrative explanation of the concept
4. **Code template** — Link to `templates/` with "copy this" instructions
5. **Modifications** — Which lines to change, why
6. **What's next** — Preview of next step
7. **Deep dive** — Links to api-reference/ for each subsystem used

**Example walkthrough** (from 01-sprite-system.md):
> "Copy `templates/sprite-example/` to your project and modify line 42 in sprites.asm to change the sprite graphic. This activates the **graphics subsystem** (handles rendering to screen) and **object-management subsystem** (tracks sprite state). For complete API details, see [graphics-subsystem.md](../api-reference/graphics-subsystem.md)."

### API Reference Files (api-reference/)

Each subsystem gets one comprehensive reference file with:

1. **Overview** — Purpose, what this subsystem does
2. **Memory layout** — Which addresses and registers it uses (e.g., video RAM, registers)
3. **Function/macro API** — Every callable routine with signatures and behavior
4. **Usage patterns** — 2-3 minimal code snippets showing common scenarios
5. **Common mistakes** — What goes wrong and how to fix it
6. **Real-world usage** — Links to how goldorak/r-type/new-game-template actually use this subsystem

### Templates (templates/)

- Minimal working code (not tutorial prose, not a full game)
- Comments mark "change this part"
- Runnable as-is (can assemble and test standalone)
- Copy-paste starting point for a specific feature

---

## Integration with Existing Resources

### Cross-linking to Real Projects

Tutorial and API docs reference existing games as "see how this is really used":
- goldorak (production game, complex patterns)
- r-type (feature-rich example, multiple subsystems interacting)
- new-game-template (minimal scaffold, good reference architecture)

Link format: `See [goldorak/game-mode/gamescreen.asm](../../game-projects/goldorak/...)`

Developers can compare minimal example (template) → tutorial walkthrough → production code (goldorak/r-type).

### New Game Creation Workflow

1. Developer follows tutorial steps 00-03 (getting-started): builds a working, playable game
2. Copies new-game-template as starting point for their own game
3. Extends based on game requirements (sound? scrolling? advanced collision?)
4. References api-reference/ when stuck on specific subsystem details

### Relationship to doc/

- **doc/** remains: processor theory, design patterns, conceptual learning (why things work)
- **tutorial/** is: practical "how to build a game right now" (what to do)
- No overlap. New developers go straight to tutorial/. Learners needing theory use doc/.

---

## Scope & Priorities

### Phase 1: Core Documentation (MVP)

Document these subsystems first (used by 95% of games):

**Core set:**
- graphics (sprites, blitting, camera)
- joypad (input handling)
- collision (hitbox detection)
- object-management (game object lifecycle, spawning, despawning)
- boot (initialization, setup)

**Secondary (high-value):**
- sound (music and SFX)
- level-management (scrolling, level data)
- palette (color effects, palette swaps)

**Total Phase 1:** 8 subsystems → 8 API reference files + 7 tutorial steps (00-06) + templates

### Phase 2: Extended Documentation (Future)

- math (fixed-point, trigonometry routines)
- keyboard (keyboard input)
- compression (sprite/tile packing)

### Phase 3: Advanced/Niche (As-needed)

- ram (memory layout deep-dive)
- irq (advanced interrupt patterns)
- system, megarom-t2, others

---

## Success Criteria

A developer should be able to:
1. Follow tutorial steps 00-03 and have a working, playable game in under 2 hours
2. Extend that game by following steps 04-07, understanding subsystem order
3. Jump to api-reference/ when they need to understand a subsystem deeply
4. Copy templates and modify them for their own game
5. Cross-reference real production code (goldorak, r-type) to see advanced patterns

---

## Implementation Plan (Next Step)

1. Create tutorial/ directory structure
2. Write tutorial steps (00-07) with walkthroughs
3. Extract/create templates/ from new-game-template and existing examples
4. Write api-reference/ files based on engine/ subsystem documentation
5. Link everything together
6. Commit and test (developer follows tutorial start-to-finish)

---

## Notes

- Tutorial assumes basic 6809 assembly knowledge (readers should know registers, addressing modes, memory)
- Not a replacement for doc/ (which covers theory)
- Templates are minimal; production code in goldorak/r-type shows advanced patterns
- Phase 1 unblocks 95% of new game creation; later phases add specialized patterns
