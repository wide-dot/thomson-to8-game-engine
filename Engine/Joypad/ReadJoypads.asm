* ---------------------------------------------------------------------------
* Controller Buttons
*
c1_button_up_mask            equ   $01 
c1_button_down_mask          equ   $02 
c1_button_left_mask          equ   $04 
c1_button_right_mask         equ   $08 
c2_button_up_mask            equ   $10 
c2_button_down_mask          equ   $20 
c2_button_left_mask          equ   $40 
c2_button_right_mask         equ   $80 
c1_button_A_mask             equ   $40 
c2_button_A_mask             equ   $80 

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

********************************************************************************
* Get joystick parameters
*
* Direction des Joypads
* ---------------------
* Registre: $E7CC (8bits)
*
* Joypad2     Joypad1
* 1111        1111 (0: appuye | 1: relache)  
* ||||_Haut   ||||_Haut
* |||__Bas    |||__Bas
* ||___Gauche ||___Gauche
* |____Droite |____Droite
*
* Boutons des Joypads
* -------------------
* Registre: $E7CD (8bits)
*
* 11 000000 (0: appuye | 1: relache) 
* ||[------] 6 bits convertisseur numerique-analogique
* ||_Fire Joypad1
* |__Fire Joypad2
*
* Variables globales: Joypads_Held, Joypads_Press
* -----------------------------------------------
* (16 bits)
* Joypad2     Joypad1                                                          
* 0000        0000 (0: relache | 1: appuye) 00 000000 (0: relache | 1: appuye)  
* ||||_Haut   ||||_Haut                     ||[------] Non utilise             
* |||__Bas    |||__Bas                      ||_Fire Joypad1                    
* ||___Gauche ||___Gauche                   |__Fire Joypad2                    
* |____Droite |____Droite                                                      
* 
********************************************************************************
   
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
