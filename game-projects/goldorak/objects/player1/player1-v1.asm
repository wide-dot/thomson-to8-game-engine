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
        lda ddJoy
        cmpa #0
        beq set0
        cmpa #1
        beq setL
        cmpa #2
        beq setR
        bra   Init_c
set0
        ldd   #Ani_Player1
        std   anim,u
        bra   Init_c
setL
        ldd   #Ani_Player1_left
        std   anim,u
        bra   Init_c
setR
        ldd   #Ani_Player1_right
        std   anim,u

Init_c  ldb   #$04
        stb   priority,u
        ldd   #$807F
        std   xy_pixel,u
        inc   routine,u
        rts

Live
            pshs a
            lda #0
            sta ddJoy
            puls a
        lda   Dpad_Held
        ldb   Fire_Press
TestLeft
        bita  #c1_button_left_mask
        beq   TestRight
        dec   x_pixel,u
            pshs a
            lda #1
            sta ddJoy
            puls a
        bra   TestUp
TestRight
        bita  #c1_button_right_mask
        beq   TestUp
        inc   x_pixel,u
            pshs a
            lda #2
            sta ddJoy
            puls a
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


ddJoy   fcb 0
