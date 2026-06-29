********************************************************************************
* Joypad : masques + variables RAM partages.
*
* Extrait de ReadJoypads.asm pour pouvoir inclure ces definitions sans tirer la
* routine ReadJoypads elle-meme (ex: R-Type stage 1 n'utilise que la variante
* ReadJoypadsKbd, mais tout le jeu lit ces masques/variables). Garde IFNDEF :
* inclure plusieurs fois est sans danger.
********************************************************************************

 ifndef joypad_const
joypad_const equ 1

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

 endc
