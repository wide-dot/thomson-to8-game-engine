cur_frame equ ext_variables        

        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Init      
        fdb   Live       
Init
        ldd   #Img_Box134
        std   image_set,u
        ldb   #$01
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask        
        sta   render_flags,u        
        inc   routine,u
        
Live
        lda   Dpad_Press
        ldb   Fire_Press
TestLeft
        bita  #c1_button_left_mask
        beq   TestRight   
        ldx   x_pos,u
        leax  -1,x
        stx   x_pos,u
        bra   TestUp
TestRight        
        bita  #c1_button_right_mask
        beq   TestUp   
        ldx   x_pos,u
        leax  1,x
        stx   x_pos,u
TestUp
        bita  #c1_button_up_mask
        beq   TestDown   
        ldx   y_pos,u
        leax  -1,x
        stx   y_pos,u
        bra   TestBtn
TestDown
        bita  #c1_button_down_mask
        beq   TestBtn   
        ldx   y_pos,u
        leax  1,x
        stx   y_pos,u
TestBtn
        bitb  #c1_button_A_mask
        beq   >
        ldx   #Frame
        lda   cur_frame,u
        inca
        cmpa  #7
        bne   @a
        lda   #0
@a      sta   cur_frame,u
        asla
        ldx   a,x
        stx   image_set,u
!       jmp   DisplaySprite

Frame
        fdb   Img_Box134
        fdb   Img_Box134M
        fdb   Img_Box134M2
        fdb   Img_Box133
        fdb   Img_Box133M
        fdb   Img_Box133M2
        fdb   Img_Tails