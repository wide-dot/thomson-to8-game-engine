; ------ keyboard-input.asm ------
; From: r-type game engine
; Example: How to read keyboard input
;
; Dependencies: keyboard subsystem

; Read keyboard input
; Output: A = key pressed (or 0 if none)
read-keyboard:
    jsr keyboard:poll-input
    rts

; Check if specific key is pressed
; Input: A = key code
; Output: A = 1 if pressed, 0 if not
is-key-pressed:
    jsr keyboard:check-key
    rts

; See full context: game-projects/r-type/keyboard module
