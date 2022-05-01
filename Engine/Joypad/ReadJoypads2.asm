********************************************************************************
* Get joystick parameters (Version 2)
*
* Read Joypads and store result as Press and Help values :
* One byte with direction and button for player 1
* One byte with direction and button for player 2
*
* Note : to have one byte for direction and another for button, use V1
* ------------------------------------------------------------------------------
*
* Joypads Direction
* -----------------
* Register: $E7CC (8bits)
*
* Joypad2     Joypad1
* 1111        1111 (0: press | 1: release)  
* ||||_Up     ||||_Up
* |||__Down   |||__Down
* ||___Left   ||___Left
* |____Right  |____Right
*
* Joypads Bouttons
* ----------------
* Register: $E7CD (8bits)
*
*   [------] 6 bits DAC
* 11 001100 (0: press | 1: release) 
* ||   ||
* ||   ||_ Btn B Joypad1
* ||   |__ Btn B Joypad2
* ||
* ||______ Btn A Joypad1
* |_______ Btn A Joypad2
*
* Result values: Joypads_Held, Joypads_Press
* -----------------------------------------------
* (16 bits)
* Joypad1
* 0000        0000 (0: release | 1: press)
* ||||_Up     ||
* |||__Down   ||
* ||___Left   ||___Btn B
* |____Right  |____Btn A
*
* Joypad2
* 0000        0000 (0: release | 1: press)
* ||||_Up     ||
* |||__Down   ||
* ||___Left   ||___Btn B
* |____Right  |____Btn A
*
********************************************************************************

; ---------------------------------------------------------------------------
; Controller Buttons
;
; Buttons bit numbers
button_up			equ   4
button_down			equ   5
button_left			equ   6
button_right			equ   7
button_B			equ   2
button_C			equ   3
button_A			equ   3
button_start			equ   3
; Buttons masks
button_up_mask			equ   %00010000
button_down_mask		equ   %00100000
button_left_mask		equ   %01000000
button_right_mask		equ   %10000000
button_B_mask			equ   %00000100
button_C_mask			equ   %00001000
button_A_mask			equ   %00001000
button_start_mask		equ   %00001000

Ctrl_1_Logical
Ctrl_1_Held_Logical		fcb   0
Ctrl_1_Press_Logical		fcb   0
Ctrl_1
Ctrl_1_Held			fcb   0
Ctrl_1_Press			fcb   0
Ctrl_2
Ctrl_2_Held			fcb   0
Ctrl_2_Press			fcb   0

ReadJoypads
        ldd   $E7CC
        ; Ctrl 1
        stb   @a
        anda  #%00001111
        lsla
        lsla
        lsla
        lsla
        andb  #%01000000
        lsrb
        lsrb
        lsrb
        stb   @b
        ldb   #0
@a      equ   *-1
        andb  #%00000100
        orb   #0
@b      equ   *-1
        stb   @c
        ora   #0
@c      equ   *-1
        coma
        sta   @d
        lda   Ctrl_1_Held
        eora  @d
        anda  @d
        sta   Ctrl_1_Press
        lda   #0
@d      equ   *-1
        sta   Ctrl_1_Held

        ldd   $E7CC
        ; Ctrl 2
        stb   @a
        anda  #%11110000
        andb  #%10000000
        lsrb
        lsrb
        lsrb
        lsrb
        stb   @b
        ldb   #0
@a      equ   *-1
        andb  #%00001000
        lsrb
        orb   #0
@b      equ   *-1
        stb   @c
        ora   #0
@c      equ   *-1
        coma
        sta   @d
        lda   Ctrl_2_Held
        eora  @d
        anda  @d
        sta   Ctrl_2_Press
        lda   #0
@d      equ   *-1
        sta   Ctrl_2_Held
        rts

