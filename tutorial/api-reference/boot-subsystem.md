# Boot Subsystem API Reference

**Author**: Claude Code  
**Version**: 1.0  
**Last Updated**: June 2026  
**Target Audience**: Intermediate 6809 programmers implementing Thomson TO8 game initialization

---

## Overview

The Boot Subsystem initializes the Thomson TO8 hardware for game execution, setting up CPU state, interrupt handlers, memory layout, stack, and entry points. It provides foundational setup required before any game logic can run, handling the transition from TO8 firmware to game code.

### Core Responsibilities

1. **CPU Initialization** — Set initial processor state and registers
2. **Memory Setup** — Initialize RAM, clear BSS, set up stack pointer
3. **Interrupt Configuration** — Install VBL handler and timer interrupts
4. **Hardware Initialization** — Initialize video, sound, input hardware
5. **Entry Point Setup** — Establish standard game loop entry point
6. **Runtime State** — Initialize global variables and game state
7. **Interrupt Enable** — Enable hardware interrupts for responsive input/timing

### Hardware Context

The Thomson TO8 boot environment:
- **CPU**: Motorola 6809 (8-bit, 16-bit address space)
- **Reset Entry**: $E000 (firmware ROM); games use $2000+ (RAM)
- **Stack**: $7FFF (top of RAM); grows downward
- **RAM Layout**: $0000–$5FFF (24 KB CPU RAM), $6000–$F8FF (40 KB video RAM)
- **Interrupts**: VBL (50 Hz), TIMER (programmable), External
- **Interrupt Vectors**: $FFE0–$FFFF (ROM; firmware provides defaults)

---

## Memory & Hardware Layout

### Thomson TO8 Memory Map

```
Address Range   Size    Purpose
─────────────────────────────────────────────────────
$0000–$1FFF     8 KB    System ROM / firmware (may be banked out)
$2000–$5FFF     16 KB   CPU RAM (game code, data, stack)
$6000–$F8FF     40 KB   Video RAM (tilemap, sprites, palette)
$F900–$F9FF     256 B   I/O Registers (PSG, timer, joypad, etc.)
$FA00–$FBFF     512 B   Banking registers
$FC00–$FDFF     512 B   Extended I/O
$FE00–$FFFF     512 B   Interrupt vectors and firmware

Typical game memory layout within $2000–$5FFF:
  $2000–$2FFF     4 KB   Game code entry (BootGame)
  $3000–$3FFF     4 KB   Game state and globals
  $4000–$4FFF     4 KB   Level data (loaded from disk)
  $5000–$5FFF     4 KB   Stack (grows down from $5FFF)
```

### Boot-Time Register Values

```
Register    Entry Value     Purpose
──────────────────────────────────────────────────────
PC          $2000           Program counter (jump here after reset)
A           Undefined       Accumulator A
B           Undefined       Accumulator B
X           Undefined       Index register X
Y           Undefined       Index register Y
U           Undefined       User stack pointer (not used)
S           $5FFF           System stack pointer (game stack)
CC          $C0             Condition code (interrupts disabled at start)
DP          $00             Direct page (firmware default)
```

### Global Game State Structure

```
Label               Address   Size   Content
──────────────────────────────────────────────────────
game_state          $3000     1      Current state (0=menu, 1=game, 2=pause)
current_level       $3001     1      Level ID (0–7)
player_x            $3002     2      Player world position X
player_y            $3004     2      Player world position Y
player_health       $3006     1      Health points
score               $3007     4      Score (big-endian)

level_id_loaded     $3100     1      Which level is loaded
object_count        $3101     1      Active objects
music_enabled       $3102     1      Music playing
sfx_queue           $3103     8      SFX queue

interrupt_count     $3200     2      Interrupt frame counter
vbl_frame           $3202     1      VBL frame number (0–49)
timer_ticks         $3203     2      Timer tick counter

error_code          $3300     1      Last error (0=none, 1=disk error, etc.)
```

### Interrupt Vector Table (ROM, $FFE0–$FFFF)

```
Offset    Interrupt Type
──────────────────────────────────────────────────
$FFE0–$FFE1     SWI3      (software interrupt 3)
$FFE2–$FFE3     SWI2      (software interrupt 2)
$FFE4–$FFE5     FIRQ      (fast interrupt request)
$FFE6–$FFE7     IRQ       (interrupt request)
$FFE8–$FFE9     SWI       (software interrupt)
$FFEA–$FFEB     NMI       (non-maskable interrupt)
$FFEC–$FFED     RESET     (power-on reset)

Game must set IRQ (VBL) and TIMER handlers:
  VBL typically uses IRQ vector
  TIMER uses firmware timer interrupt
```

---

## Public Functions

### BootGame — Initialize game and start main loop

```asm
; Game entry point; called from firmware after ROM setup
;
; Entry:
;   None (called by firmware)
;
; Exit:
;   Never (enters infinite game loop)
;
; Uses: All registers
;
; Notes:
;   - First instruction executed by game code
;   - Must initialize all subsystems
;   - Establishes VBL and timer interrupts
;   - Enters main game loop (never returns)
;   - Memory must be cleared before calling subsystem inits

BootGame:
        ; Initialize stack pointer
        lds   #$5FFF           ; Stack at top of RAM
        
        ; Clear CPU RAM ($2000–$5FFF for BSS)
        ldx   #$2000
        ldy   #$4000
        clra
.clear_loop:
        sta   ,x+              ; Zero byte
        cmpx  #$5FFF
        bne   .clear_loop
        
        ; Initialize system globals
        lda   #0
        sta   game_state
        sta   current_level
        
        ; Initialize subsystems
        jsr   InitializeGraphics
        jsr   InitializeSound
        jsr   InitializeInput
        jsr   InitializeInterrupts
        jsr   InitializeObjects
        
        ; Load first level
        lda   #0
        jsr   LoadLevel
        
        ; Enable interrupts
        andcc #$AF             ; Clear I and F flags (enable IRQ and FIRQ)
        
        ; Enter main game loop
        jmp   MainGameLoop
```

### SetInterruptHandler — Install custom interrupt handler

```asm
; Register a handler for VBL or TIMER interrupt
;
; Entry:
;   A = Interrupt type (0=VBL, 1=TIMER)
;   X = Handler routine address (code to execute on interrupt)
;
; Exit:
;   Interrupt vector installed; handler will be called
;
; Uses: A, X
;
; Notes:
;   - VBL fires every frame (50 Hz on TO8)
;   - TIMER fires at configurable interval
;   - Handler must preserve registers (or save/restore)
;   - Handler must end with RTI (return from interrupt)
;   - Maximum one handler per interrupt type

SetInterruptHandler:
        ; Save handler address in interrupt handler table
        cmp   #0               ; Check interrupt type
        bne   .check_timer
        
        ; VBL handler
        stx   vbl_handler_ptr
        rts
        
.check_timer:
        cmp   #1
        bne   .invalid
        
        ; TIMER handler
        stx   timer_handler_ptr
        rts
        
.invalid:
        rts
```

### InitMemory — Clear RAM and initialize memory regions

```asm
; Initialize CPU RAM to known state
;
; Entry:
;   None
;
; Exit:
;   RAM ($2000–$5FFF) cleared to zero
;   BSS segment initialized
;
; Uses: All registers
;
; Notes:
;   - Called during game boot
;   - Clears stack space and uninitialized data
;   - Does not clear video RAM ($6000+)
;   - Does not initialize global variables
;   - Video RAM is separately managed

InitMemory:
        ; Clear CPU RAM
        ldx   #$2000
        clra
        
.loop:
        sta   ,x+              ; Zero each byte
        cmpx  #$6000           ; Stop at video RAM
        bne   .loop
        
        rts
```

### EnableInterrupts — Turn on CPU interrupts

```asm
; Enable CPU to process interrupts
;
; Entry:
;   None
;
; Exit:
;   CPU ready to handle VBL and TIMER interrupts
;
; Uses: None (CC register only)
;
; Notes:
;   - Clears I and F condition code bits
;   - Must be called after interrupt handlers are installed
;   - Without this, interrupts are disabled and timers hang
;   - Called near end of BootGame

EnableInterrupts:
        andcc #$AF             ; Clear I (IRQ) and F (FIRQ) flags
        rts
```

### DisableInterrupts — Turn off CPU interrupts

```asm
; Disable CPU from processing interrupts
;
; Entry:
;   None
;
; Exit:
;   CPU ignores interrupts
;
; Uses: None (CC register only)
;
; Notes:
;   - Sets I and F condition code bits
;   - Used for critical sections (no interruption allowed)
;   - Temporary; re-enable with EnableInterrupts
;   - Overuse causes input lag and missed VBL updates

DisableInterrupts:
        orcc  #$50             ; Set I (IRQ) and F (FIRQ) flags
        rts
```

### InitializeInterrupts — Set up VBL and TIMER

```asm
; Configure interrupt hardware and install default handlers
;
; Entry:
;   None
;
; Exit:
;   VBL interrupt ready (fires 50 times per second)
;   TIMER interrupt ready (if used)
;
; Uses: All registers
;
; Notes:
;   - Installs default VBL handler (updates input, audio, objects)
;   - Installs default TIMER handler (if needed)
;   - Does not enable interrupts (call EnableInterrupts)
;   - VBL is mandatory for game loop synchronization

InitializeInterrupts:
        ; Install VBL handler
        ldx   #VBL_Handler
        lda   #0               ; Type 0 = VBL
        jsr   SetInterruptHandler
        
        ; Install TIMER handler (if used)
        ldx   #TIMER_Handler
        lda   #1               ; Type 1 = TIMER
        jsr   SetInterruptHandler
        
        ; Initialize interrupt counters
        clr   vbl_frame_number
        lda   #0
        sta   interrupt_count
        sta   interrupt_count+1
        
        rts
```

---

## Common Patterns

### Minimal Boot Sequence

The most basic game boot:

```asm
; Minimal game with just graphics and input
BootMinimalGame:
        lds   #$5FFF           ; Set stack
        
        jsr   InitMemory       ; Clear RAM
        jsr   InitializeGraphics
        jsr   InitializeInput
        jsr   InitializeInterrupts
        jsr   SetInterruptHandler  ; Install VBL
        
        andcc #$AF             ; Enable interrupts
        
        ; Load first level
        lda   #0
        jsr   LoadLevel
        
        ; Main game loop
.loop:
        jsr   UpdateInput
        jsr   UpdatePlayer
        jsr   RenderFrame
        jsr   WaitVBL
        bra   .loop
```

### Full Boot with Audio and Objects

Complete initialization for complex game:

```asm
; Full game with music, sound, objects, enemies
BootCompleteGame:
        lds   #$5FFF           ; Stack
        
        ; Initialize all systems
        jsr   InitMemory
        jsr   InitializeGraphics
        jsr   InitializeSound
        jsr   InitializeInput
        jsr   InitializeInterrupts
        jsr   InitializeObjects
        
        ; Install custom interrupt handlers
        ldx   #CustomVBL_Handler
        lda   #0
        jsr   SetInterruptHandler
        
        ; Enable interrupts
        andcc #$AF
        
        ; Load level and start music
        lda   #0
        jsr   LoadLevel
        lda   #MUSIC_INTRO
        jsr   SoundPlayMusic
        
        ; Main game loop
.loop:
        jsr   UpdateInput
        jsr   UpdatePlayer
        jsr   UpdateEnemies
        jsr   UpdateObjects
        jsr   UpdateCamera
        jsr   RenderFrame
        jsr   WaitVBL
        bra   .loop
```

### Critical Section (Disable/Enable Interrupts)

Protecting shared data:

```asm
UpdateSharedCounter:
        ; Counter is modified by both main loop and VBL interrupt
        
        jsr   DisableInterrupts ; Prevent interrupt mid-update
        
        ; Read-modify-write without interruption
        lda   shared_counter
        adda  #1
        sta   shared_counter
        
        jsr   EnableInterrupts
        
        rts
```

### VBL Handler Template

Default VBL interrupt implementation:

```asm
VBL_Handler:
        pshs  a,b,x,y,u       ; Save registers (required)
        
        ; Increment frame counter
        inc   interrupt_count
        bne   .no_carry
        inc   interrupt_count+1
        
.no_carry:
        ; Update music
        jsr   VBL_UpdateMusic
        
        ; Update sound effects
        jsr   VBL_UpdateSFX
        
        ; Update objects
        jsr   VBL_UpdateObjects
        
        ; Handle palette fades
        jsr   VBL_UpdatePalette
        
        puls  a,b,x,y,u,pc    ; Restore and return
```

---

## Common Mistakes

### Mistake 1: Stack Overflow from Incorrect Stack Pointer

**The Problem**:
```asm
; WRONG: Stack pointer set too low
BootGame:
        lds   #$4000           ; Stack at middle of RAM
        
        ; Game runs for a bit, then crashes
        ; Stack grows downward and corrupts game data
        ; Variables at $3FFF–$2000 are overwritten
```

**Why It Fails**:
- 6809 stack grows downward (decreasing addresses)
- Setting S to low address means stack immediately corrupts data below
- First few function calls corrupt variables
- Causes unpredictable crashes and memory corruption

**The Fix**:
```asm
; RIGHT: Stack pointer at top of RAM
BootGame:
        lds   #$5FFF           ; Stack at top of available RAM
        
        ; Stack grows downward safely
        ; Collides with game code only if deeply nested
```

**Lesson**: Always set stack to highest available RAM address ($5FFF on TO8). Stack grows downward; wrong address = immediate corruption.

---

### Mistake 2: Interrupts Enabled Before Handlers Installed

**The Problem**:
```asm
; WRONG: Enable interrupts before setting handlers
BootGame:
        lds   #$5FFF
        
        andcc #$AF             ; Enable interrupts too early!
        
        jsr   InitializeInterrupts  ; Install handlers (too late)
        
        ; VBL fires immediately but handler_ptr is uninitialized
        ; Jump to garbage address, crash
```

**Why It Fails**:
- VBL interrupt fires at 50 Hz (every 20 ms)
- If enabled before handlers installed, PC jumps to uninitialized memory
- Immediate crash at first VBL (worst case: 20 ms after boot)
- Difficult to debug (happens very quickly)

**The Fix**:
```asm
; RIGHT: Install handlers before enabling interrupts
BootGame:
        lds   #$5FFF
        
        jsr   InitializeInterrupts  ; Install handlers first
        
        andcc #$AF             ; Enable interrupts now (safe)
```

**Lesson**: Always install interrupt handlers before calling `EnableInterrupts`. Order matters for safety.

---

### Mistake 3: Not Clearing RAM BSS Segment

**The Problem**:
```asm
; WRONG: Assume RAM is pre-cleared
BootGame:
        lds   #$5FFF
        ; Skip InitMemory call
        
        jsr   InitializeObjects    ; Tries to read object pool
        
        ; Object pool contains garbage (previous program's data)
        ; Objects spawn with undefined positions and velocities
        ; Game crashes immediately
```

**Why It Fails**:
- RAM is not automatically cleared on boot (it's persistent)
- Previous programs leave data in RAM
- Uninitialized variables contain garbage
- Behavior is unpredictable frame-to-frame

**The Fix**:
```asm
; RIGHT: Always clear RAM first
BootGame:
        lds   #$5FFF
        
        jsr   InitMemory           ; Clear entire RAM region
        
        jsr   InitializeObjects    ; Now RAM is clean
        jsr   InitializeGraphics
        ; ... etc
```

**Lesson**: Always call `InitMemory` first thing after setting stack. RAM persists across program runs.

---

### Mistake 4: Critical Section with Interrupts Enabled

**The Problem**:
```asm
; WRONG: Read-modify-write without disabling interrupts
UpdateGameCounter:
        lda   game_counter
        adda  #1
        sta   game_counter     ; Interrupt might fire here!
        rts

; If VBL fires after ADD but before STA:
;   - VBL handler reads/modifies game_counter
;   - STA writes old value back (increment lost)
;   - Counter is corrupted
```

**Why It Fails**:
- Multi-instruction operations are not atomic
- Interrupt can fire between instructions
- Main loop and interrupt handler modify same variable
- Result is lost or corrupted data

**The Fix**:
```asm
; RIGHT: Disable interrupts for shared variable access
UpdateGameCounter:
        jsr   DisableInterrupts
        
        lda   game_counter
        adda  #1
        sta   game_counter     ; Interrupt cannot fire here
        
        jsr   EnableInterrupts
        
        rts
```

**Lesson**: Disable interrupts before accessing shared variables modified by interrupt handlers. Re-enable after.

---

### Mistake 5: Handler Doesn't Preserve Registers

**The Problem**:
```asm
; WRONG: Interrupt handler doesn't save registers
VBL_Handler:
        lda   #1               ; Modify A
        jsr   UpdateSomething  ; Uses X, Y
        rts                    ; Return without restoring!

; Main loop expects A, X, Y unchanged:
        lda   player_x         ; VBL modified A!
        adda  #1
        ; Result is wrong because A was clobbered
```

**Why It Fails**:
- Main loop is interrupted mid-instruction
- Registers (A, X, Y, etc.) are in use
- If handler clobbers them, main loop continues with wrong values
- Causes subtle, hard-to-debug corruption

**The Fix**:
```asm
; RIGHT: Handler saves and restores all registers
VBL_Handler:
        pshs  a,b,x,y,u       ; Save all registers
        
        lda   #1
        jsr   UpdateSomething
        
        puls  a,b,x,y,u,pc    ; Restore and return
```

**Lesson**: Interrupt handlers MUST preserve all registers (A, B, X, Y, U). Use PSHS/PULS to save/restore.

---

## Real-World Usage

### Goldorak Game Boot

Goldorak initializes full game subsystems:

```asm
; From goldorak/boot/BootGoldorakGame.asm

BootGoldorakGame:
        ; Initialize CPU
        lds   #$5FFF           ; Set stack
        
        ; Initialize memory
        jsr   InitMemory       ; Clear RAM
        
        ; Initialize hardware subsystems
        jsr   InitializeGraphics   ; Video
        jsr   InitializeSound      ; PSG audio
        jsr   InitializeInput      ; Joypad
        jsr   InitializeInterrupts ; VBL, TIMER
        jsr   InitializeObjects    ; Object pool
        
        ; Install custom handlers
        ldx   #GoldorakVBL_Handler
        lda   #0               ; VBL
        jsr   SetInterruptHandler
        
        ; Initialize game state
        lda   #GAME_STATE_INTRO
        sta   game_state
        lda   #0
        sta   current_level
        
        ; Load introduction sequence
        jsr   LoadIntroScreen
        lda   #MUSIC_INTRO
        jsr   SoundPlayMusic
        
        ; Enable interrupts
        andcc #$AF
        
        ; Main game loop
        jmp   MainGameLoop
```

### R-Type Boot Sequence

R-Type with dynamic level loading:

```asm
; From game-projects/r-type/boot/BootRType.asm

BootRType:
        lds   #$5FFF
        jsr   InitMemory
        
        jsr   InitializeGraphics
        jsr   InitializeSound
        jsr   InitializeInput
        jsr   InitializeInterrupts
        jsr   InitializeObjects
        
        ; Start at level 1
        lda   #1
        sta   current_level
        jsr   LoadLevel
        
        ; Initialize player
        jsr   InitializePlayer
        
        ; Install R-Type specific VBL handler
        ldx   #RTypeVBL_Handler
        lda   #0
        jsr   SetInterruptHandler
        
        andcc #$AF             ; Go!
        
.main_loop:
        jsr   UpdateGame
        jsr   UpdateInput
        jsr   UpdateCamera
        jsr   RenderFrame
        jsr   WaitVBL
        
        lda   game_state
        cmp   #GAME_OVER
        beq   .show_game_over
        
        bra   .main_loop
        
.show_game_over:
        jsr   ShowGameOverScreen
        bra   .main_loop
```

### VBL Handler for 50 Hz Game Loop

Standard VBL implementation:

```asm
; From engine/interrupt/VBL_Handler.asm

VBL_Handler:
        pshs  a,b,x,y,u
        
        ; Increment global frame counter
        inc   vbl_frame_number
        cmp   #50              ; Wrap at 2.5 seconds
        bne   .no_wrap
        clr   vbl_frame_number
        
.no_wrap:
        ; Update music playback
        jsr   VBL_UpdateMusic
        
        ; Update sound effects queue
        jsr   VBL_UpdateSFX
        
        ; Update game objects
        jsr   VBL_UpdateGameObjects
        
        ; Handle palette transitions
        jsr   VBL_UpdatePaletteFade
        
        ; Input is sampled here
        jsr   VBL_ReadInput
        
        puls  a,b,x,y,u,pc
```

---

## Further Reading

**Related API References**:
- **VBL Interrupt Handler** — Timing synchronization for game loop
- **Graphics Subsystem** — Display initialization
- **Sound Subsystem** — Audio hardware setup
- **Input System** — Joypad controller initialization

**Engine Source Code**:
- `/engine/boot/BootGame.asm` — Main game entry point
- `/engine/interrupt/VBL_Handler.asm` — VBL interrupt implementation
- `/engine/interrupt/TimerHandler.asm` — Timer interrupt (if used)
- `/engine/memory/InitMemory.asm` — RAM initialization

**Tutorial References**:
- `tutorial/getting-started/00-minimal-game.md` — Minimal boot sequence
- `tutorial/extending/01-interrupt-handlers.md` — Custom VBL handlers
- `tutorial/patterns/game-startup.md` — Full initialization sequence

**Hardware Documentation**:
- Thomson TO8 Technical Manual — Memory map and interrupt vectors
- Motorola 6809 Reference — Interrupt handling and stack operations

---

**End of Boot Subsystem API Reference**

Generated: June 2026  
Quality Level: Production-Ready
