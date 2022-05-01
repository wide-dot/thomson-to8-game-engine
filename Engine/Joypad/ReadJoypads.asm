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

; dedicated mask
c1_button_up_mask            equ   %00000001 
c1_button_down_mask          equ   %00000010 
c1_button_left_mask          equ   %00000100 
c1_button_right_mask         equ   %00001000 
c1_button_A_mask             equ   %01000000 
c1_button_B_mask             equ   %00000100 

c2_button_up_mask            equ   %00010000 
c2_button_down_mask          equ   %00100000  
c2_button_left_mask          equ   %01000000 
c2_button_right_mask         equ   %10000000 
c2_button_A_mask             equ   %10000000 
c2_button_B_mask             equ   %00001000 

; common mask
c_button_up_mask             equ   %00010001 
c_button_down_mask           equ   %00100010 
c_button_left_mask           equ   %01000100 
c_button_right_mask          equ   %10001000 
c_button_A_mask              equ   %11000000 
c_button_B_mask              equ   %00001100 

; player mask
c1_dpad                      equ   %00001111 
c2_dpad                      equ   %11110000
c1_butn                      equ   %01000100 
c2_butn                      equ   %10001000 

Joypads_Read
Dpad_Read                    fcb   $00
Fire_Read                    fcb   $00
   
Joypads
Joypads_Held                           
Dpad_Held                    fcb   $00 
Fire_Held                    fcb   $00 
Joypads_Press                          
Dpad_Press                   fcb   $00 
Fire_Press                   fcb   $00 

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
        eora  Dpad_Read                *    eor.b   d0,d1             ; Toggle off buttons that are being held                       
        eorb  Fire_Read
                                       *    move.b  d0,(a0)+          ; Put raw controller input (for held buttons) in F604/F606
        anda  Dpad_Read                *    and.b   d0,d1
        andb  Fire_Read
        std   Joypads_Press            *    move.b  d1,(a0)+          ; Put pressed controller input in F605/F607
        ldd   Joypads_Read
        std   Joypads_Held
        rts                            *    rts
                                       *; End of function Joypad_Read
