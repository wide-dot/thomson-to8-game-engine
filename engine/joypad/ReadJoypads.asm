********************************************************************************
* Get joystick parameters (Version 1)
*
* Read Joypads and store result as Press and Help values :
* One byte with direction for player 1 and player 2
* One byte with button for player 1 and player 2
*
* Note : to have one byte for each player, use V2
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
* Joypad2     Joypad1
* 0000        0000 (0: release | 1: press) 00 000000 (0: release | 1: press)
* ||||_Up     ||||_Up                       ||  ||
* |||__Down   |||__Down                     ||  ||_ Btn B Joypad1
* ||___Left   ||___Left                     ||  |__ Btn B Joypad2
* |____Right  |____Right                    ||_____ Btn A Joypad1
*                                           |______ Btn A Joypad2
********************************************************************************

; masques + variables RAM partages (Joypads_Read/Held/Press, masks). Sortis ici
; pour pouvoir les inclure sans tirer la routine (cf. ReadJoypadsKbd / stage 1).
        INCLUDE "./engine/joypad/joypad.const.asm"

                                       *; ---------------------------------------------------------------------------
                                       *; Subroutine to read joypad input, and send it to the RAM
                                       *; ---------------------------------------------------------------------------
                                       *; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
                                       *
                                       *; sub_111C:
ReadJoypads                            *ReadJoypads:
                                       *    lea (Ctrl_1).w,a0         ; address where joypad states are written
                                       *    lea (HW_Port_1_Data).l,a1 ; first joypad port
                                       *    bsr.s   Joypad_Read       ; do the first joypad
                                       *    addq.w  #2,a1             ; do the second joypad
                                       *
                                       *; sub_112A:
                                       *Joypad_Read:
                                       *    move.b  #0,(a1)           ; Poll controller data port
                                       *    nop
                                       *    nop
                                       *    move.b  (a1),d0           ; Get controller port data (start/A)
                                       *    lsl.b   #2,d0
                                       *    andi.b  #$C0,d0
                                       *    move.b  #$40,(a1)         ; Poll controller data port again
                                       *    nop
                                       *    nop
                                       *    move.b  (a1),d1           ; Get controller port data (B/C/Dpad)
                                       *    andi.b  #$3F,d1
                                       *    or.b    d1,d0             ; Fuse together into one controller bit array
        ldd   $E7CC
        coma
        comb                           *    not.b   d0
        std   Joypads_Read
        ldd   Joypads_Held             *    move.b  (a0),d1           ; Get held button data
        eora  Dpad_Read                *    eor.b   d0,d1             ; Toggle off buttons that were previously being held
        eorb  Fire_Read
                                       *    move.b  d0,(a0)+          ; Put raw controller input (for held buttons) in F604/F606
        anda  Dpad_Read                *    and.b   d0,d1
        andb  Fire_Read
        std   Joypads_Press            *    move.b  d1,(a0)+          ; Put pressed controller input in F605/F607
        ldd   Joypads_Read
        std   Joypads_Held
        rts                            *    rts
                                       *; End of function Joypad_Read
