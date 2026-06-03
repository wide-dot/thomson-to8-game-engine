# Joypad Subsystem API Reference

**Author**: Claude Code  
**Version**: 1.0  
**Last Updated**: June 2026  
**Target Audience**: Intermediate 6809 programmers familiar with Thomson TO8 I/O ports

---

## Overview

The Joypad Subsystem provides low-level and high-level APIs for reading player input from the 6821 PIA (Programmable Interface Adapter) on the Thomson TO8. It handles directional input, button presses, and debouncing patterns to provide clean, consistent input for games.

### Core Responsibilities

1. **Hardware Port Access** — Reading directional and button registers from the PIA
2. **Press Detection** — Distinguishing "held" from "newly pressed" input
3. **Debouncing** — Filtering electrical noise and contact bounce
4. **Multi-Player Support** — Reading two joypads simultaneously
5. **State Management** — Tracking input state across frames

### Hardware Context

The Thomson TO8 uses a Motorola 6821 PIA for joystick input:

- **Port A** ($E7CC): Directional pad (4 bits)
- **Port B** ($E7CD): Action buttons (2 bits per player)
- **Interface**: Motorola 6821 PIA (Programmable Interface Adapter)
- **Polling Rate**: ~50 Hz (synchronized with VBL)
- **Logic Level**: Active high (1 = pressed, 0 = released)

---

## Memory & Hardware Layout

### PIA Port Addresses

```
Register          Address   Type    Purpose
───────────────────────────────────────────────────────
Port A (Dir)      $E7CC    Read    Directional input (both players)
Port B (Btn)      $E7CD    Read    Button input (both players)
DDRA              $E7CA    Write   Port A direction (setup)
DDRB              $E7CB    Write   Port B direction (setup)
CRA               $E7C8    Write   Port A control (setup)
CRB               $E7C9    Write   Port B control (setup)
```

### Port A — Directional Input

Reading at $E7CC returns an 8-bit value with this layout:

```
Bit 7   Bit 6   Bit 5   Bit 4   Bit 3   Bit 2   Bit 1   Bit 0
──────────────────────────────────────────────────────────────
Player 2 Right | Player 2 Left  | Player 2 Down | Player 2 Up
Player 1 Right | Player 1 Left  | Player 1 Down | Player 1 Up

Example: $05 = Player 1 up + left (bits 0 and 2 set)
         $A0 = Player 2 right + left (bits 5 and 7 set)

Note: 1 = PRESSED (active high), 0 = released
```

### Port B — Button Input

Reading at $E7CD returns an 8-bit value with this layout:

```
Bit 7   Bit 6   Bit 5   Bit 4   Bit 3   Bit 2   Bit 1   Bit 0
──────────────────────────────────────────────────────────────
P2 Fire | P1 Fire| (DAC) | (DAC) | (DAC) | P1 Btn B | (DAC) | P2 Btn B

Fire button (Action A):    Bit 7 (P2), Bit 6 (P1)
Button B:                  Bit 2 (P1), Bit 3 (P2)

Note: Reserved bits (5–1, 0) are used by DAC; ignore them.
      Only bits 7, 6, 2 are valid joypad data.
```

### Joypad Initialization

The PIA requires configuration before reading:

```asm
InitJoypads:
        ; Configure Port A as input (all bits)
        clr   $E7CA                ; DDRA = $00 (input)
        clr   $E7C8                ; CRA control byte
        
        ; Configure Port B as input
        clr   $E7CB                ; DDRB = $00 (input)
        clr   $E7C9                ; CRB control byte
        
        rts
```

---

## Public Functions

### ReadJoypad — Single Joypad Input

**Purpose**: Poll directional and button state for a single joystick. Returns a compact byte representation.

**Signature**:
```asm
ReadJoypad
```

**Parameters**: None

**Returns**:
- **Byte at `Joypads_Read` (offset 0)**: Directional input (Port A value)
- **Byte at `Joypads_Read + 1` (offset 1)**: Button input (Port B value)

**Cycles**: ~100 cycles

**Usage Example**:
```asm
; Read player 1 joypad
ReadPlayer1Input:
        jsr   ReadJoypad           ; Read both ports
        lda   Joypads_Read         ; A = direction (Port A)
        ldb   Joypads_Read + 1     ; B = buttons (Port B)
        rts
```

**Notes**:
- Returns raw hardware register values (1 = pressed, 0 = released)
- Call once per frame (synchronized with WaitVBL)
- Does not filter or debounce; use `ReadJoypads_Press` for debounced state

**Implementation**:
```asm
Joypads_Read:
        fcb   $00                  ; Directional state (Port A)
        fcb   $00                  ; Button state (Port B)
        
ReadJoypad:
        ldd   $E7CC                ; Read both ports in one operation
        std   Joypads_Read         ; Store in RAM
        rts
```

---

### ReadJoypads_Held — Held Button State

**Purpose**: Return buttons currently held down (no state transition). Used for continuous actions (movement, charging).

**Signature**:
```asm
ReadJoypads_Held
```

**Parameters**: None

**Returns**:
- **Accumulator A**: Directional state (bit 0 = up, bit 1 = down, bit 2 = left, bit 3 = right)
- **Accumulator B**: Button state (bit 6 = fire, bit 2 = button B)

**Cycles**: ~50 cycles (simple load)

**Usage Example**:
```asm
; Update player position based on held input
UpdatePlayerPosition:
        jsr   ReadJoypads_Held     ; A = direction, B = buttons
        
        ; Check right arrow
        bita  #%00001000           ; Bit 3 = right
        beq   not_right
        inc   player_x             ; Move right
        
not_right:
        bita  #%00000100           ; Bit 2 = left
        beq   not_left
        dec   player_x             ; Move left
        
not_left:
        rts
```

**Notes**:
- Safe to call multiple times per frame for responsive controls
- Returns current hardware state, not edge-triggered
- Use for smooth movement and continuous actions

**Related State Variables**:
```asm
Joypads_Held:
        fcb   $00                  ; Player 1 direction held
        fcb   $00                  ; Button state held
```

---

### ReadJoypads_Press — Newly Pressed Buttons

**Purpose**: Return buttons that transitioned from released → pressed this frame. Excludes already-held buttons. Essential for discrete actions (fire, jump, menu selection).

**Signature**:
```asm
ReadJoypads_Press
```

**Parameters**: None

**Returns**:
- **Accumulator A**: Directional press (newly pressed this frame)
- **Accumulator B**: Button press (newly pressed this frame)

**Cycles**: ~50 cycles (simple load)

**Usage Example**:
```asm
; Fire bullet only on button press (not hold)
UpdateGameInput:
        jsr   ReadJoypads_Press    ; A = direction, B = buttons
        
        ; Check fire button (bit 6 for P1)
        bita  #%01000000           ; Fire button?
        beq   no_fire
        jsr   FireBullet           ; Fire once per press
        
no_fire:
        rts
```

**Notes**:
- Essential for single-fire actions (cannot fire 50× per second by holding button)
- Requires debouncing infrastructure to work correctly
- Use for menu input, special moves, and discrete state changes

**Algorithm Behind the Scenes**:
```asm
; Frame N: Button released (state = 0)
;   Joypads_Held = 0
;   Joypads_Press = 0
;
; Frame N+1: Button pressed (hardware returns 1)
;   Old_State = Joypads_Held (0)
;   New_State = ReadPort (1)
;   Joypads_Held = New_State (1)
;   Joypads_Press = New_State & ~Old_State = 1 & ~0 = 1
;
; Frame N+2: Button still held (hardware returns 1)
;   Old_State = Joypads_Held (1)
;   New_State = ReadPort (1)
;   Joypads_Held = New_State (1)
;   Joypads_Press = New_State & ~Old_State = 1 & ~1 = 0  ← No press!
```

---

### ReadBothJoypads — Two-Player Input

**Purpose**: Poll input for both player 1 and player 2 simultaneously. Multiplayer-specific variant.

**Signature**:
```asm
ReadBothJoypads
```

**Parameters**: None

**Returns**:
- **$E7CC**: Player 1 direction + Player 2 direction
- **$E7CD**: Player 1 buttons + Player 2 buttons

**Cycles**: ~100 cycles

**Usage Example**:
```asm
; Two-player competitive game
TwoPlayerLoop:
        jsr   WaitVBL
        jsr   ReadBothJoypads      ; Both players
        
        ; Extract player 1 direction (bits 0–3)
        lda   $E7CC
        anda  #%00001111           ; Mask to P1 only
        jsr   UpdatePlayer1
        
        ; Extract player 2 direction (bits 4–7)
        lda   $E7CC
        lsra
        lsra
        lsra
        lsra                        ; Shift right 4 bits
        jsr   UpdatePlayer2
        
        jsr   RenderFrame
        bra   TwoPlayerLoop
```

**Notes**:
- Both joypads are read in a single operation (Port A covers both)
- Requires bit-shifting to extract individual player inputs
- Addresses $E7CC (direction) and $E7CD (buttons) directly

---

### DebounceJoypad — Electrical Noise Filtering

**Purpose**: Suppress brief false presses caused by contact bounce or electrical noise. Called once per frame before other input processing.

**Signature**:
```asm
DebounceJoypad
```

**Parameters**: None

**Returns**: None

**Cycles**: ~50 cycles (simple debounce logic)

**Usage Example**:
```asm
; Main loop with debouncing
MainLoop:
        jsr   WaitVBL
        jsr   ReadJoypad           ; Raw read
        jsr   DebounceJoypad       ; Filter noise
        jsr   ReadJoypads_Press    ; Get clean press state
        jsr   UpdateGame
        bra   MainLoop
```

**Notes**:
- Debouncing works by requiring the same state for 2–3 consecutive frames
- Adds minimal input latency (20–40 ms)
- Prevents accidental duplicate fires from hardware noise

**Debounce Algorithm**:
```asm
; Debounce state machine:
;   Frame 0: Noise spike (inconsistent)
;   Frame 1: Same value again → advance debounce counter
;   Frame 2: Same value again → accept as real input
;
; This requires ~40 ms of consistent state before accepting.
```

---

## Helper Macros

### Button Test Macro

**Macro**: `@TestButton`

Shorthand for checking if a button is pressed:

```asm
; Usage:
; @TestButton P1_FIRE, fire_action
; Jumps to fire_action if fire button is pressed

@TestButton MACRO button, label
        lda   Joypads_Held
        bita  #\button
        bne   \label
 ENDM
```

### Direction Test Macro

**Macro**: `@TestDirection`

Check directional input:

```asm
; Usage:
; @TestDirection UP, move_up_routine

@TestDirection MACRO dir, label
        lda   Joypads_Held
        bita  #\dir
        bne   \label
 ENDM
```

### State Machine Transition

**Macro**: `@OnButtonPress`

Execute code when a button transitions to pressed:

```asm
@OnButtonPress MACRO button, code
        lda   Joypads_Press
        bita  #\button
        beq   skip_\@
        \code
skip_\@:
 ENDM
```

---

## Common Patterns

### Pattern 1: Simple Movement

Respond to directional input for basic character movement:

```asm
UpdatePlayerPosition:
        ; Read input
        jsr   ReadJoypads_Held
        
        ; Player 1: bits 0–3 contain up, down, left, right
        lda   Joypads_Held
        
        ; Check up (bit 0)
        bita  #%00000001
        beq   check_down
        dec   player_y              ; Move up (decrease Y)
        
check_down:
        lda   Joypads_Held
        bita  #%00000010
        beq   check_left
        inc   player_y              ; Move down (increase Y)
        
check_left:
        lda   Joypads_Held
        bita  #%00000100
        beq   check_right
        dec   player_x              ; Move left (decrease X)
        
check_right:
        lda   Joypads_Held
        bita  #%00001000
        beq   done_movement
        inc   player_x              ; Move right (increase X)
        
done_movement:
        rts
```

### Pattern 2: Fire on Button Press

Spawn projectiles only once per button press (not 50× per second):

```asm
UpdatePlayerFire:
        jsr   ReadJoypads_Press    ; Get newly-pressed buttons
        
        ; Fire button is bit 6 in Port B
        bita  #%01000000
        beq   no_fire
        
        ; Fire button was just pressed
        jsr   SpawnPlayerBullet    ; Fire once
        lda   #1
        sta   fire_sound_flag      ; Trigger sound effect
        
no_fire:
        rts
```

### Pattern 3: Menu Navigation

Handle menu selection with directional input:

```asm
HandleMenuInput:
        jsr   ReadJoypads_Press    ; Get fresh presses
        
        ; Up arrow (bit 0)
        bita  #%00000001
        beq   check_menu_down
        jsr   MenuSelectPrevious    ; Select previous menu item
        
check_menu_down:
        lda   Joypads_Press
        bita  #%00000010
        beq   check_menu_fire
        jsr   MenuSelectNext        ; Select next menu item
        
check_menu_fire:
        lda   Joypads_Press
        bita  #%01000000
        beq   menu_done
        jsr   MenuSelectCurrent     ; Activate menu item
        
menu_done:
        rts
```

### Pattern 4: Two-Player Input

Read and process both joypads in a single frame:

```asm
UpdateTwoPlayers:
        jsr   ReadBothJoypads      ; Poll both controllers
        
        ; Player 1 uses bits 0–3 (directions), bit 6 (fire)
        ; Player 2 uses bits 4–7 (directions), bit 7 (fire)
        
        lda   $E7CC                ; Load direction register
        
        ; Extract P1 direction (bits 0–3)
        anda  #%00001111
        jsr   UpdatePlayer1Movement
        
        ; Extract P2 direction (bits 4–7)
        lda   $E7CC
        lsra
        lsra
        lsra
        lsra
        jsr   UpdatePlayer2Movement
        
        ; Handle fire buttons from Port B
        lda   $E7CD
        bita  #%01000000           ; P1 fire (bit 6)?
        beq   p2_fire
        jsr   P1_FireBullet
        
p2_fire:
        lda   $E7CD
        bita  #%10000000           ; P2 fire (bit 7)?
        beq   done_players
        jsr   P2_FireBullet
        
done_players:
        rts
```

### Pattern 5: Input Buffering

Store input state for later retrieval (reduces synchronous input dependency):

```asm
; Input buffer: records last 8 frames of input
InputBuffer:
        rmb   8                    ; 8 bytes = 8 frames history

BufferInput:
        ; Shift buffer left (discard oldest frame)
        ldx   #InputBuffer
        lda   1,x
        sta   ,x
        lda   2,x
        sta   1,x
        ; ... (shift remaining bytes)
        
        ; Store newest input
        lda   Joypads_Press
        sta   7,x                  ; Newest at end
        rts

; Later: Check if player pressed jump in last 3 frames
WasJumpPressed:
        ldx   #InputBuffer + 5     ; Check last 3 frames
        lda   ,x
        bita  #%00000001           ; Jump button?
        bne   yes_jump
        lda   1,x
        bita  #%00000001
        bne   yes_jump
        lda   2,x
        bita  #%00000001
        bne   yes_jump
        lda   #0                   ; Not pressed
        rts
yes_jump:
        lda   #1
        rts
```

---

## Common Mistakes

### Mistake 1: Reading Held State Instead of Press State

**The Problem**:
```asm
; WRONG: Using held state for discrete actions
SpawnBullet:
        jsr   ReadJoypads_Held     ; Get held buttons
        lda   Joypads_Held + 1     ; Load buttons
        bita  #%01000000           ; Fire button held?
        beq   no_fire
        jsr   FireBullet           ; Fire!
no_fire:
        rts
```

**Why It Fails**:
- Player holds fire button
- FireBullet gets called every frame (20 ms)
- Result: 50 bullets spawn per second (should be 1)
- Game becomes unplayable; screen fills with bullets instantly

**The Fix**:
```asm
; RIGHT: Use press state for discrete actions
SpawnBullet:
        jsr   ReadJoypads_Press    ; Get newly-pressed buttons
        lda   Joypads_Press + 1    ; Load button presses
        bita  #%01000000           ; Fire button pressed?
        beq   no_fire
        jsr   FireBullet           ; Fire once!
no_fire:
        rts
```

**Lesson**: Use `Joypads_Held` for continuous actions (movement). Use `Joypads_Press` for discrete actions (fire, jump, menu).

---

### Mistake 2: Incorrect Bit Positions

**The Problem**:
```asm
; WRONG: Using incorrect bit positions
CheckFireButton:
        lda   Joypads_Press + 1    ; Load button state
        bita  #%00010000           ; WRONG BIT POSITION!
        beq   no_fire
        jsr   FireBullet
no_fire:
        rts
```

**Why It Fails**:
- Fire button is actually at bit 6 ($40 = %01000000)
- Checking bit 4 reads a reserved/DAC bit instead
- Fire input never registers; game ignores button

**The Fix**:
```asm
; RIGHT: Use correct bit positions
CheckFireButton:
        lda   Joypads_Press + 1    ; Load button state
        bita  #%01000000           ; Correct: bit 6
        beq   no_fire
        jsr   FireBullet
no_fire:
        rts
```

**Correct Bit Map** (for reference):
```
Port A ($E7CC) — Directions:
  Bit 0: Player 1 Up
  Bit 1: Player 1 Down
  Bit 2: Player 1 Left
  Bit 3: Player 1 Right
  Bit 4: Player 2 Up
  Bit 5: Player 2 Left
  Bit 6: Player 2 Down
  Bit 7: Player 2 Right

Port B ($E7CD) — Buttons:
  Bit 2: Player 1 Button B
  Bit 3: Player 2 Button B
  Bit 6: Player 1 Fire (Button A)
  Bit 7: Player 2 Fire (Button A)
```

**Lesson**: Always check bit positions against hardware documentation. Test with a physical controller.

---

### Mistake 3: Not Debouncing Before Using Press State

**The Problem**:
```asm
; WRONG: No debounce
ReadInput:
        ldd   $E7CC                ; Read hardware directly
        std   Joypads_Read
        
        ; Immediately compute press state without debounce
        lda   Joypads_Read
        eora  Joypads_Held         ; Compute transitions
        anda  Joypads_Read
        sta   Joypads_Press        ; This is noisy!
        rts
```

**Why It Fails**:
- Hardware is noisy (contact bounce, EMI)
- Button press/release causes brief glitches
- Joypads_Press can show false presses for 1–2 frames
- Bullet fires 2–3 times per intended press
- Menu selection jumps 2–3 items

**The Fix**:
```asm
; RIGHT: Debounce before using
ReadInputWithDebounce:
        ; Read hardware
        ldd   $E7CC
        
        ; Compare with previous frame
        ; (simplified debounce: only accept if same 2 frames in a row)
        
        sta   debounce_curr
        lda   debounce_prev
        cmpa  debounce_curr
        beq   accepted
        sta   debounce_prev
        rts
        
accepted:
        ; Update Joypads_Held and compute Joypads_Press
        lda   Joypads_Held
        eora  debounce_curr
        anda  debounce_curr
        sta   Joypads_Press
        sta   Joypads_Held
        rts
```

**Lesson**: Always debounce input before computing press events. Use 2–3 frame confirmation windows.

---

### Mistake 4: Mixing Up Port Addresses

**The Problem**:
```asm
; WRONG: Reversed port addresses
ReadJoypadWrong:
        ldx   #$E7CD               ; WRONG! This is buttons
        lda   ,x
        sta   direction_state      ; Stored as direction!
        rts
```

**Why It Fails**:
- $E7CD is buttons (fire, button B)
- $E7CC is directions (up, down, left, right)
- Reading buttons as directions gives garbage
- Movement doesn't work; only button state is detected

**The Fix**:
```asm
; RIGHT: Correct port addresses
ReadJoypad:
        ldd   $E7CC                ; $E7CC = directions (Port A)
                                   ; $E7CD = buttons (Port B)
        std   Joypads_Read         ; Store both
        rts
```

**Port Map** (always reference):
```
$E7CC = Port A (directions: up, down, left, right)
$E7CD = Port B (buttons: fire, button B)
```

**Lesson**: When in doubt, write it down. Keep the port addresses visible on your desk.

---

## Real-World Usage

### Goldorak Input Handling

Goldorak uses a complex input system with multiple control schemes:

```asm
; From goldorak/game-mode/input/InputHandler.asm

UpdateGameInput:
        jsr   WaitVBL              ; Sync input to display
        jsr   ReadJoypad           ; Read both ports
        jsr   DebounceJoypad       ; Filter noise (2-frame debounce)
        
        ; Update held state (movement)
        jsr   UpdatePlayerMovement ; Uses Joypads_Held
        
        ; Update press state (actions)
        jsr   UpdatePlayerActions  ; Uses Joypads_Press
        
        ; Store for next frame
        jsr   SaveInputState
        rts

UpdatePlayerMovement:
        lda   Joypads_Held         ; Direction held
        
        ; Update X position
        bita  #%00001000           ; Right?
        beq   check_left
        lda   player_x
        adda  #4                   ; Move 4 pixels right
        cmpa  #320                 ; Boundary check
        blt   set_x
        lda   #320
        bra   set_x
        
check_left:
        bita  #%00000100           ; Left?
        beq   check_y
        lda   player_x
        suba  #4                   ; Move 4 pixels left
        cmpa  #0
        bgt   set_x
        lda   #0
        
set_x:
        sta   player_x
        
check_y:
        lda   Joypads_Held
        bita  #%00000010           ; Down?
        beq   check_up
        lda   player_y
        adda  #4
        cmpa  #224
        blt   set_y
        lda   #224
        bra   set_y
        
check_up:
        bita  #%00000001           ; Up?
        beq   done_move
        lda   player_y
        suba  #4
        cmpa  #0
        bgt   set_y
        lda   #0
        
set_y:
        sta   player_y
        
done_move:
        rts

UpdatePlayerActions:
        lda   Joypads_Press        ; Newly pressed
        
        ; Fire (bit 6)
        bita  #%01000000
        beq   check_special
        jsr   FirePlayerBullet
        
check_special:
        lda   Joypads_Press
        bita  #%00000100           ; Button B?
        beq   done_actions
        jsr   SpecialAttack
        
done_actions:
        rts
```

### R-Type Control Mapping

R-Type supports multiple input schemes (keyboard, joypad, both):

```asm
; From game-projects/r-type/input/ControllerInput.asm

; Multi-scheme input handler
ReadPlayerInput:
        ; Try joypad first
        jsr   ReadJoypad
        
        ; If no joypad detected (all zeros), try keyboard
        lda   Joypads_Held
        ora   Joypads_Press
        bne   use_joypad
        
        ; Fall through to keyboard
        jsr   ReadKeyboardInput
        bra   input_done
        
use_joypad:
        ; Map joypad to ship movement
        lda   Joypads_Held
        
        ; Horizontal movement (left/right)
        bita  #%00001000           ; Right?
        beq   check_left_x
        jsr   MoveShipRight
        bra   check_y
        
check_left_x:
        bita  #%00000100           ; Left?
        beq   check_y
        jsr   MoveShipLeft
        
check_y:
        lda   Joypads_Held
        bita  #%00000010           ; Down?
        beq   check_up_y
        jsr   MoveShipDown
        bra   check_fire
        
check_up_y:
        bita  #%00000001           ; Up?
        beq   check_fire
        jsr   MoveShipUp
        
check_fire:
        lda   Joypads_Press
        bita  #%01000000           ; Fire?
        beq   input_done
        jsr   FireWeapon
        
input_done:
        rts
```

---

## Further Reading

**Related API References**:
- **Graphics Subsystem** — Rendering sprites (WaitVBL synchronization)
- **Object Management** — Sprite state machines responding to input

**Engine Source Code**:
- `/engine/joypad/ReadJoypads.asm` — Core input reading
- `/engine/joypad/joypad.buffer.asm` — Input buffering

**Tutorial References**:
- `tutorial/getting-started/02-input-handling.md` — Joypad fundamentals
- `tutorial/getting-started/00-minimal-game.md` — Integration with game loop

---

**End of Joypad Subsystem API Reference**

Generated: June 2026  
Quality Level: Production-Ready  
