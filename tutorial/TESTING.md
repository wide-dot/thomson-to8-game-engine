# Tutorial Testing Procedure

This document provides a step-by-step procedure to verify that the Thomson TO8 Game Engine tutorial works end-to-end, producing a complete working game.

## Overview

The tutorial is divided into two phases:
- **Phase 1** (Steps 00-03): Create a minimal working game with sprites, input, and collision (~2 hours)
- **Phase 2** (Steps 04-06): Extend with sound, levels, and advanced collision (~3-4 hours)

Each step is testable independently and builds on the previous steps.

---

## Phase 1: Getting Started (Steps 00-03)

### Success Criteria for Phase 1
By the end of Phase 1, you should have a playable game featuring:
- Boot sequence completed with memory and graphics initialized
- At least one sprite displayed on screen
- Joypad input responsiveness (directional movement)
- Simple collision detection (boundary checking)
- A functioning game loop

**Time Estimate**: 90-120 minutes

---

### Step 00: Boot & Minimal Game Structure

**Objective**: Set up the core game loop and display a static sprite.

**Location**: `tutorial/getting-started/00-minimal-game.md`

#### Test Procedure

1. **Read the tutorial step** (15 minutes)
   - Understand the boot process and why initialization order matters
   - Review the 6809 assembly basics and game loop structure
   - Study the three-phase initialization (Boot → Graphics → Objects)

2. **Build the minimal game template** (15 minutes)
   ```bash
   cd tutorial/templates/minimal-game
   # Follow the platform-specific build instructions in README.md
   ```

3. **Reference the API** (10 minutes if needed)
   - See `tutorial/api-reference/boot-subsystem.md` for memory setup details
   - See `tutorial/api-reference/graphics-subsystem.md` for display mode initialization

4. **Run the game** (5 minutes)
   - Launch the compiled ROM in your TO8 emulator (e.g., DCMOTO, MAME)
   - Expected output: A black screen (or default color) with no errors

**Success Criteria**:
- ROM compiles without errors
- Game loads in emulator without crashes
- No corruption in display memory

#### Troubleshooting Step 00

| Issue | Cause | Solution |
|-------|-------|----------|
| Compilation fails with undefined symbols | Missing includes or incorrect paths | Check that `cfg/` directory is present and config file matches your platform |
| Game crashes on startup | Boot code not executing | Verify RAM initialization addresses are correct for TO8 (0xA000-0xBFFF for game RAM) |
| Display garbled or black | Graphics mode not initialized | Ensure graphics setup runs before first sprite render |

---

### Step 01: Sprite System

**Objective**: Display a moving sprite and understand sprite lifecycle.

**Location**: `tutorial/getting-started/01-sprite-system.md`

#### Test Procedure

1. **Read the tutorial step** (15 minutes)
   - Understand sprite data structures and how sprites are stored
   - Review sprite positioning and animation frame management
   - Study the sprite pooling pattern used in the engine

2. **Use the sprite example template** (15 minutes)
   ```bash
   cd tutorial/templates/sprite-example
   # Integrate sprite.asm into your minimal game from Step 00
   ```

3. **Reference the API** (10 minutes if needed)
   - See `tutorial/api-reference/graphics-subsystem.md` for rendering details
   - See `tutorial/api-reference/object-management.md` for sprite lifecycle

4. **Run the game** (5 minutes)
   - Expected output: A sprite visible on the screen (typically in top-left corner)
   - Verify sprite does not flicker or corrupt memory

**Success Criteria**:
- Sprite renders without visual artifacts
- Sprite data is properly aligned in memory
- No stack corruption or memory overwrites

#### Troubleshooting Step 01

| Issue | Cause | Solution |
|-------|-------|----------|
| Sprite not visible | Rendering coordinates out of bounds | Check sprite X/Y positions are within screen bounds (0-319 pixels wide, 0-199 pixels tall in 256-color mode) |
| Sprite flickers | Frame timing issue | Ensure sprite rendering happens once per frame, not in a tight loop |
| Memory corruption | Incorrect sprite data alignment | Verify sprite data is word-aligned (even addresses) in memory |

---

### Step 02: Input Handling

**Objective**: Read joypad input and update sprite position in response.

**Location**: `tutorial/getting-started/02-input-handling.md`

#### Test Procedure

1. **Read the tutorial step** (15 minutes)
   - Understand PIA (Peripheral Interface Adapter) port configuration for joypad
   - Review debouncing and polling patterns
   - Study the input state machine used in the engine

2. **Use the input example template** (15 minutes)
   ```bash
   cd tutorial/templates/input-example
   # Integrate input.asm into your sprite-based game from Step 01
   ```

3. **Reference the API** (10 minutes if needed)
   - See `tutorial/api-reference/joypad-subsystem.md` for detailed port mappings

4. **Run and test the game** (10 minutes)
   - Connect a joypad or use emulator keyboard/gamepad mapping
   - Press arrow keys or move the physical joypad
   - Expected output: Sprite moves in response to input

**Test Input Directions**:
- Up arrow / Joypad UP → Sprite moves up
- Down arrow / Joypad DOWN → Sprite moves down
- Left arrow / Joypad LEFT → Sprite moves left
- Right arrow / Joypad RIGHT → Sprite moves right
- Fire button (Spacebar or Joypad FIRE) → No visual change yet (prepared for Phase 2)

**Success Criteria**:
- Input responds within 1 frame (16ms at 60 FPS)
- Sprite moves smoothly in all four directions
- No input lag or stuttering
- Fire button is recognized (logged or queued for later use)

#### Troubleshooting Step 02

| Issue | Cause | Solution |
|-------|-------|----------|
| Joypad input not recognized | PIA port not configured | Verify port A and B are set to input mode in `$A7C0` register |
| Sprite moves only in one direction | Bit masking incorrect | Check that joypad read routine correctly masks individual direction bits |
| Sprite moves too fast or too slow | Update increment too large or small | Adjust sprite X/Y delta per frame (typically 2-4 pixels per frame) |

---

### Step 03: Collision Detection

**Objective**: Implement simple boundary checking and prepare for shape-based collisions.

**Location**: `tutorial/getting-started/03-collision-detection.md`

#### Test Procedure

1. **Read the tutorial step** (20 minutes)
   - Understand bounding box collision and boundary conditions
   - Review collision response strategies (bounce, stop, wrap)
   - Study the collision callback system

2. **Use the collision example template** (15 minutes)
   ```bash
   cd tutorial/templates/collision-example
   # Integrate collision.asm into your input-driven game from Step 02
   ```

3. **Reference the API** (15 minutes if needed)
   - See `tutorial/api-reference/collision-subsystem.md` for mask-based collision details

4. **Run and test the game** (10 minutes)
   - Move the sprite in all directions toward screen edges
   - Expected output: Sprite stops at screen boundaries (does not leave visible area)

**Test Collision Scenarios**:
- Move sprite to left edge → Stops at X=0
- Move sprite to right edge → Stops at X=max (screen width - sprite width)
- Move sprite to top edge → Stops at Y=0
- Move sprite to bottom edge → Stops at Y=max (screen height - sprite height)

**Success Criteria**:
- Sprite cannot move off-screen
- Collision detection registers all four boundaries
- No visual glitches at boundary conditions
- Sprite stops smoothly without stuttering

#### Troubleshooting Step 03

| Issue | Cause | Solution |
|-------|-------|----------|
| Sprite leaves screen edges | Boundary check condition incorrect | Verify comparison operators (< and >) in boundary check code |
| Collision stops working after first hit | Collision flag not reset | Ensure collision state is cleared each frame after processing |
| Sprite sticks to edges | Off-by-one error in boundary math | Check that boundary limits account for sprite width/height |

---

## Phase 1 Verification Checklist

After completing all Phase 1 steps, run this checklist:

- [ ] Step 00: Game boots without errors
- [ ] Step 01: Sprite displays on screen
- [ ] Step 02: Joypad input moves sprite in four directions
- [ ] Step 03: Sprite respects screen boundaries
- [ ] All four steps are buildable and runnable independently
- [ ] No memory corruption in any step
- [ ] No flickering or visual artifacts
- [ ] Game runs for 5+ minutes without crashing

**Phase 1 Complete**: You have a working game with graphics, input, and collision detection!

---

## Phase 2: Extending (Steps 04-06)

### Success Criteria for Phase 2
By the end of Phase 2, you should have a complete game featuring:
- Background music and sound effects (from Step 04)
- Scrolling levels with tile-based maps (from Step 05)
- Advanced collision detection with multiple objects (from Step 06)
- Frame-rate stable gameplay at 60 FPS

**Time Estimate**: 180-240 minutes (3-4 hours)

---

### Step 04: Sound & Music

**Objective**: Add background music and sound effects to the game.

**Location**: `tutorial/extending/04-sound-and-music.md`

#### Test Procedure

1. **Read the tutorial step** (20 minutes)
   - Understand the sound synthesizer architecture (6809-based wave generation)
   - Review envelope control (ADSR: Attack, Decay, Sustain, Release)
   - Study PCM sample playback and music sequencing

2. **Use the sound example template** (20 minutes)
   ```bash
   cd tutorial/templates/sound-example
   # Integrate sound.asm into your Phase 1 game
   ```

3. **Reference the API** (15 minutes if needed)
   - See `tutorial/api-reference/sound-subsystem.md` for envelope and timing details

4. **Run and test the game** (10 minutes)
   - Expected output: Background music plays during game loop
   - Sound effects trigger when sprite moves or collides

**Test Sound Scenarios**:
- Game starts → Background music begins
- Sprite moves → Sound effect plays (optional, depends on implementation)
- Sprite hits boundary → Collision sound plays (optional)

**Success Criteria**:
- Music plays continuously without stuttering
- Sound effects trigger without disrupting music
- Audio remains in sync with game logic
- No crackling or audio artifacts

#### Troubleshooting Step 04

| Issue | Cause | Solution |
|-------|-------|----------|
| No sound output | Audio subsystem not initialized | Check that sound ROM and synthesizer are enabled at boot time |
| Sound is distorted or crackles | Envelope timing too fast | Increase ADSR attack/decay times (values typically 10-100ms) |
| Music plays but sounds wrong | Note frequency off | Verify frequency table is correct for target musical scale |
| Sound interferes with input | Audio interrupt priority too high | Adjust interrupt priority so joypad polling still happens every frame |

---

### Step 05: Level Scrolling

**Objective**: Implement tile-based maps and camera scrolling.

**Location**: `tutorial/extending/05-level-scrolling.md`

#### Test Procedure

1. **Read the tutorial step** (25 minutes)
   - Understand tile map structure (typically 8x8 or 16x16 pixel tiles)
   - Review layer rendering and scroll offset management
   - Study dynamic level loading and memory management

2. **Use the scrolling levels template** (20 minutes)
   ```bash
   cd tutorial/templates/scrolling-levels
   # Integrate level.asm into your Phase 1 + sound game
   ```

3. **Reference the API** (15 minutes if needed)
   - See `tutorial/api-reference/level-management.md` for tile encoding and layer format

4. **Run and test the game** (15 minutes)
   - Move sprite around the game level
   - Expected output: Camera follows sprite and level scrolls smoothly

**Test Level Scenarios**:
- Move sprite left → Level scrolls left, revealing new tiles
- Move sprite right → Level scrolls right
- Move sprite up → Level scrolls up
- Move sprite down → Level scrolls down
- Reach level boundary → Camera stops, sprite continues moving freely

**Success Criteria**:
- Level scrolls smoothly without jitter or tearing
- Camera follows sprite without lag
- Tile rendering has no artifacts or missing tiles
- Level wrapping works correctly at boundaries (if implemented)

#### Troubleshooting Step 05

| Issue | Cause | Solution |
|-------|-------|----------|
| Level does not scroll | Scroll offset not applied to rendering | Check that camera position is updated each frame and applied to sprite/tile rendering |
| Level scrolls but sprite stays in place | Camera updates but sprite not constrained to viewport | Ensure sprite stays centered on screen (or at intended offset) as camera moves |
| Tiles appear corrupted when scrolling | Tile address calculation wrong | Verify tile data addresses account for scroll offset correctly |
| Level scrolling stutters | Frame timing issue or memory contention | Ensure scrolling update happens once per frame, before rendering |

---

### Step 06: Advanced Collision

**Objective**: Implement shape-based collision detection for complex game objects.

**Location**: `tutorial/extending/06-advanced-collision.md`

#### Test Procedure

1. **Read the tutorial step** (25 minutes)
   - Understand collision masks and shape-based detection
   - Review multi-object collision checking
   - Study collision response strategies (bounce, slide, stop)

2. **Use the collision example template** (upgraded version if available)
   - Apply advanced collision concepts to your Phase 2 game

3. **Reference the API** (20 minutes if needed)
   - See `tutorial/api-reference/collision-subsystem.md` for mask-based collision section

4. **Run and test the game** (15 minutes)
   - Add multiple sprites or enemies to your level
   - Expected output: Collision detection works between sprite and enemies, sprite and level geometry

**Test Collision Scenarios**:
- Sprite collides with enemy sprite → Collision callback triggers
- Sprite collides with level geometry (walls, platforms) → Collision response (stop or slide)
- Multiple enemies collide with each other → All collisions detected
- Collision response is appropriate (bounce vs. stop) → Game feels responsive

**Success Criteria**:
- All collision pairs are detected correctly
- Collision responses are physically plausible (no overlap after collision)
- Collision detection runs at frame rate without slowdown
- Complex shapes (non-rectangular) are handled correctly

#### Troubleshooting Step 06

| Issue | Cause | Solution |
|-------|-------|----------|
| Collisions not detected | Collision mask not set or bounds not calculated | Verify sprite collision masks are correctly defined in memory |
| Sprite passes through colliders | Collision check skipped or response not applied | Ensure collision response is applied before sprite rendering |
| Performance drops with many objects | Collision checking O(n²) | Optimize by spatial partitioning (quadtree, grid) or early rejection tests |
| Collision response too aggressive | Response force too high | Adjust collision response magnitude (typically 2-4 pixels separation) |

---

## Phase 2 Verification Checklist

After completing all Phase 2 steps, run this checklist:

- [ ] Step 04: Background music plays smoothly
- [ ] Step 04: Sound effects trigger without disruption
- [ ] Step 05: Level scrolls smoothly with camera following sprite
- [ ] Step 05: All tiles render correctly during scrolling
- [ ] Step 06: Sprite collides correctly with multiple objects
- [ ] Step 06: Collision responses are appropriate
- [ ] Entire Phase 2 game runs for 10+ minutes without crashing
- [ ] Frame rate remains steady (60 FPS or target rate) throughout gameplay
- [ ] No memory leaks or corruption

**Phase 2 Complete**: You have a complete game engine with audio, levels, and advanced collision!

---

## Full Game Verification

After completing all steps in both phases:

1. **Play the game for 15 minutes straight**
   - Move around the level, trigger collisions, listen to audio
   - Verify responsiveness and stability

2. **Test edge cases**
   - Move to all corners of all levels
   - Trigger multiple simultaneous collisions
   - Play game continuously for 30+ minutes (stress test)

3. **Verify performance**
   - Frame rate remains stable (no drops below target)
   - Audio remains in sync with game
   - No memory growth over time

4. **Cross-reference templates**
   - Verify all six templates (minimal-game, sprite-example, input-example, collision-example, sound-example, scrolling-levels) work independently and can be combined

---

## Build & Run Commands Reference

### Minimal Game Template
```bash
cd tutorial/templates/minimal-game
# Read platform-specific build steps in README.md
# Typical Linux/macOS:
./build.sh
# Copy resulting ROM to emulator
```

### Sprite Example
```bash
cd tutorial/templates/sprite-example
# Build with your 6809 assembler (e.g., togen, cc90)
togen sprite.asm -o sprite.o
```

### Input Example
```bash
cd tutorial/templates/input-example
# Build similarly
togen input.asm -o input.o
```

### Collision Example
```bash
cd tutorial/templates/collision-example
# Build and link
togen collision.asm -o collision.o
```

### Sound Example
```bash
cd tutorial/templates/sound-example
# Build with sound resources
togen sound.asm -o sound.o
```

### Scrolling Levels
```bash
cd tutorial/templates/scrolling-levels
# Build with tile/map resources
togen level.asm -o level.o
```

---

## Common Issues & Solutions

### General Issues

| Issue | Solution |
|-------|----------|
| Emulator not recognizing ROM | Verify ROM header is correct (Thomson TO8 format, not MO5/MO6) |
| Build tools not found | Verify `togen`, `cc90`, or equivalent is in PATH; see `tutorial/api-reference/boot-subsystem.md` for build tool setup |
| Game runs but no display | Verify graphics mode is initialized before first sprite render |
| Game crashes randomly | Enable memory guard/protections in emulator to detect overwrites |

### Debugging

1. **Add logging**
   - Insert debugging code that writes status to a reserved screen area
   - Example: Display current sprite position and frame counter

2. **Use emulator breakpoints**
   - Set breakpoints on input routine, collision check, or rendering
   - Step through code to identify where things go wrong

3. **Memory inspection**
   - In emulator, dump memory regions where sprites and game state are stored
   - Look for corruption patterns

---

## Time Estimates Summary

| Phase | Steps | Time | Outcome |
|-------|-------|------|---------|
| Phase 1 | 00-03 | 90-120 min | Working game with input and collision |
| Phase 2 | 04-06 | 180-240 min | Complete game with audio, levels, advanced collision |
| **Total** | **00-06** | **270-360 min (4.5-6 hours)** | **Production-ready game engine** |

---

## Next Steps After Tutorial

Once you've completed the tutorial:

1. **Study real-world examples**
   - See `game-projects/goldorak/` and `game-projects/r-type/` for production game code
   - Trace how those projects use the subsystems taught in the tutorial

2. **Extend your game**
   - Add more levels, sprites, and game mechanics
   - Implement game states (menu, pause, game over)
   - Add difficulty progression or enemy AI

3. **Optimize for hardware**
   - Profile your game to find bottlenecks
   - Refer to `tutorial/api-reference/` for low-level optimization tips
   - Use hardware tricks (double buffering, sprite multiplexing) to maximize performance

4. **Join the community**
   - Contribute improvements back to the tutorial
   - Share your games and techniques with other Thomson TO8 developers
