        INCLUDE "./engine/macros.asm"   

SpecialSonic
        lda   routine,u
        asla
        ldx   #SpecialSonic_Routines
        jmp   [a,x]

SpecialSonic_Routines
        fdb   Init
        fdb   Move
Init
        ldd   #Ani_SSonicRunFlat
        std   anim,u
        ldb   #$03
        stb   priority,u
        ldd   #$80B9
        std   xy_pixel,u
        inc   routine,u
Move
        lda   Dpad_Held
        ldb   Fire_Press
TestLeft
        bita  #c1_button_left_mask
        beq   TestRight   
        lda   x_pixel,u
        suba  #$04
        sta   x_pixel,u
        bra   TestUp
TestRight        
        bita  #c1_button_right_mask
        beq   TestUp   
        lda   x_pixel,u
        adda  #$04
        sta   x_pixel,u
TestUp
        bita  #c1_button_up_mask
        beq   TestDown   
        lda   y_pixel,u
        suba  #$04
        sta   y_pixel,u
        bra   TestBtn
TestDown
        bita  #c1_button_down_mask
        beq   TestBtn   
        lda   y_pixel,u
        adda  #$04
        sta   y_pixel,u
TestBtn
        bitb  #c1_button_A_mask
        beq   Continue
        lda   glb_Next_Game_Mode
        sta   GameMode
        lda   #$FF
        sta   ChangeGameMode
Continue
        jsr   AnimateSprite   
        jmp   DisplaySprite