; Minimal joypad input reading example for Thomson TO8
; This code shows how to:
; 1. Read the joypad state
; 2. Check for button presses
; 3. Handle direction input
; 4. Debounce input

; ==================== CONSTANTS ====================

; Thomson TO8 hardware ports
PIA_PORTB       equ $E7CB       ; Joypad input port
PIA_CTRL_B      equ $E7CF       ; PIA control register

; Joypad button bits (in PIA_PORTB)
JOYPAD_UP       equ 0           ; bit 0
JOYPAD_DOWN     equ 1           ; bit 1
JOYPAD_LEFT     equ 2           ; bit 2
JOYPAD_RIGHT    equ 3           ; bit 3
JOYPAD_BUTTON1  equ 4           ; bit 4 (Fire)
JOYPAD_BUTTON2  equ 5           ; bit 5

; ==================== DATA ====================

    org $2000

; Current joypad state (1 = pressed)
CurrentJoypadState: fcb 0

; Previous joypad state (for edge detection)
PreviousJoypadState: fcb 0

; ==================== MAIN LOOP ====================

Start:
    ; Read joypad continuously
    jsr ReadJoypad
    
    ; Check for specific button presses
    jsr CheckInputs
    
    ; Loop
    bra Start

; ==================== READ JOYPAD ====================
; Output:
;   CurrentJoypadState = joypad button bits (0 = pressed, 1 = not pressed)

ReadJoypad:
    lda PIA_PORTB           ; Read joypad port
    
    ; Store current state
    sta CurrentJoypadState
    
    rts

; ==================== CHECK INPUT ====================
; Detect rising edges (button pressed this frame)

CheckInputs:
    lda CurrentJoypadState
    ldb PreviousJoypadState
    
    eora b                  ; XOR: bits that changed
    anda CurrentJoypadState ; Keep only new presses (1->0 transition)
    
    ; CHANGE THIS: Handle specific buttons
    ; Bit 0 = UP, Bit 1 = DOWN, Bit 2 = LEFT
    ; Bit 3 = RIGHT, Bit 4 = BUTTON1, Bit 5 = BUTTON2
    
    ; Example: Check if UP pressed
    tst a
    bpl NotUp               ; Skip if no change
    bmi UpPressed
    
NotUp:
    ; Continue with other buttons...
    
    ; Update previous state for next frame
    lda CurrentJoypadState
    sta PreviousJoypadState
    
    rts

UpPressed:
    ; CHANGE THIS: Do something when UP is pressed
    ; e.g., move player up, scroll menu, etc.
    jsr MoveUp
    bra NotUp

; ==================== MOVEMENT HANDLERS ====================

MoveUp:
    ; CHANGE THIS: Implement your up movement
    rts

MoveDown:
    ; CHANGE THIS: Implement your down movement
    rts

MoveLeft:
    ; CHANGE THIS: Implement your left movement
    rts

MoveRight:
    ; CHANGE THIS: Implement your right movement
    rts

ButtonPressed:
    ; CHANGE THIS: Implement your button press action
    rts

; ==================== HELPER: GET BUTTON STATE ====================
; Input:
;   A = bit mask (e.g., $01 for UP)
; Output:
;   Z flag = 1 if pressed, 0 if not pressed

IsButtonPressed:
    ldb CurrentJoypadState
    anda b                  ; A & CurrentJoypadState
    rts

; ==================== END OF FILE ====================
