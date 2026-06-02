; ------ input-polling.asm ------
; From: r-type game engine
; Example: How to read joystick input each frame
;
; Usage:
;   1. Call joypad:poll-input to read current input state
;   2. Check input flags (A register bits) for button state
;   3. Call object/player logic functions based on input
;
; Dependencies: joypad subsystem

; Read joystick state and update player
; This runs each frame in the main game loop
poll-player-input:
    jsr joypad:poll-input    ; Read joystick (returns A = input flags)

    ; Check for directions: bits 4,5,6,7 = up,down,left,right
    bit #$10             ; Bit 4 = joystick up?
    beq not-up
    jsr player:move-up
not-up:
    bit #$20             ; Bit 5 = joystick down?
    beq not-down
    jsr player:move-down
not-down:
    bit #$40             ; Bit 6 = joystick left?
    beq not-left
    jsr player:move-left
not-left:
    bit #$80             ; Bit 7 = joystick right?
    beq not-right
    jsr player:move-right
not-right:

    ; Check for fire button (bit 0-3)
    bit #$01             ; Bit 0 = fire button?
    beq not-fire
    jsr player:fire-weapon
not-fire:

    rts

; See full context: game-projects/r-type/main-loop or input handling
