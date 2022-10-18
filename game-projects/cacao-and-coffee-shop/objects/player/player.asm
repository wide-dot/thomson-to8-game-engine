; ---------------------------------------------------------------------------
; Object - Player
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm" 

Player
        lda   routine,u
        asla
        ldx   #Player_Routines
        jmp   [a,x]

Player_Routines
        fdb   Init      
        fdb   Live   

Init
        ldd   #Ani_Player
        std   anim,u
        ldb   #$04
        stb   priority,u
        ldd   #$807F
        std   xy_pixel,u
        inc   routine,u
        rts
        
Live
        lda   Dpad_Held
        ldb   Fire_Press
TestLeft
        bita  #c1_button_left_mask
        beq   TestRight   
        dec   x_pixel,u
        bra   TestUp
TestRight        
        bita  #c1_button_right_mask
        beq   TestUp   
        inc   x_pixel,u
TestUp
        bita  #c1_button_up_mask
        beq   TestDown   
        dec   y_pixel,u
        bra   Anim
TestDown
        bita  #c1_button_down_mask
        beq   Anim   
        inc   y_pixel,u
Anim
        jsr   AnimateSprite   
        jmp   DisplaySprite

