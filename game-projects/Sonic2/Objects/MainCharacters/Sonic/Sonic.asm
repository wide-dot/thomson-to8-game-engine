; ---------------------------------------------------------------------------
; Object - Sonic
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./Engine/Macros.asm"   

TestImageSet
        lda   routine,u
        asla
        ldx   #TitleScreen_Routines
        jmp   [a,x]

TitleScreen_Routines
        fdb   Init
        fdb   Move
Init
        ldd   #SonAni_Walk
        std   anim,u
        ldb   #$04
        stb   priority,u
        ldd   #$807F
        std   xy_pixel,u
        inc   routine,u
Move
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
        bra   TestBtn
TestDown
        bita  #c1_button_down_mask
        beq   TestBtn   
        inc   y_pixel,u
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
