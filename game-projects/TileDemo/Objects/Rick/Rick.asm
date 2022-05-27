; ---------------------------------------------------------------------------
; Object - Rick
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./Engine/Macros.asm" 

Rick
        lda   routine,u
        asla
        ldx   #Rick_Routines
        jmp   [a,x]

Rick_Routines
        fdb   Init      
        fdb   Live
        fdb   Stop        
Init
        ldd   #Ani_rick_walk
        std   anim,u
        ldb   #$04
        stb   priority,u
        ldd   #$0050
        std   x_pos,u
        ldd   #$0063
        std   y_pos,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask        
        sta   render_flags,u        
        inc   routine,u
        rts
        
Live
        lda   Dpad_Held
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
        leax  -2,x
        stx   y_pos,u
        bra   TestBtn
TestDown
        bita  #c1_button_down_mask
        beq   TestBtn   
        ldx   y_pos,u
        leax  2,x
        stx   y_pos,u
TestBtn
        ;bitb  #c1_button_A_mask
        ;beq   SetAutoScroll
        ;lda   glb_Next_Game_Mode
        ;sta   GameMode
        ;lda   #$FF
        ;sta   ChangeGameMode
SetAutoScroll
        ldd   <glb_camera_y_pos
        addd  #32+10   ; rick sprite height is supposed 21, sprite is centered, so add 21/2
        cmpd  y_pos,u
        blo   @a
	    lda   #scroll_state_up
        bra   @b
@a	    addd  #128-10               ; rick sprite height is supposed 21, sprite is centered, so sub 21/2
        cmpd  y_pos,u
        bhi   @c
        lda   #scroll_state_down
@b      sta   glb_auto_scroll_state
        ldd   #8                    ; auto scroll 8 frames
        std   glb_auto_scroll_frames
        ldd   #$0800                ; auto scroll 8 pixels by frame
        std   glb_auto_scroll_step
        inc   routine,u
@c      jsr   AnimateSprite   
        jmp   DisplaySprite
        
Stop
        tst   glb_auto_scroll_state
        bne   @a
        dec   routine,u
        bra   Live
@a      jmp   DisplaySprite
