; ---------------------------------------------------------------------------
; Object - Link
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./Engine/Macros.asm" 

Link
        lda   routine,u
        asla
        ldx   #Link_Routines
        jmp   [a,x]

Link_Routines
        fdb   Init      
        fdb   Live
        fdb   Stop        
Init
        ldd   #Ani_link_walk_down
        std   anim,u
        ldb   #$04
        stb   priority,u
        ldd   #$01A7-screen_left
        std   x_pos,u
        ldd   #$0236-screen_top
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
        ldd   #Ani_link_walk_side
        std   anim,u   
        lda   status_flags,u
        anda  #^status_xflip_mask        
        sta   status_flags,u                   
        cmpx  glb_vp_x_min 
        bhi   @a
        bra   Stall
@a      stx   x_pos,u
        bra   TestBtn
TestRight        
        bita  #c1_button_right_mask
        beq   TestUp   
        ldx   x_pos,u
        leax  1,x
        ldd   #Ani_link_walk_side
        std   anim,u        
        lda   status_flags,u
        ora   #status_xflip_mask        
        sta   status_flags,u           
        cmpx  glb_vp_x_max 
        blo   @b
        bra   Stall                
@b      stx   x_pos,u
        bra   TestBtn               
TestUp
        bita  #c1_button_up_mask
        beq   TestDown   
        ldx   y_pos,u
        leax  -2,x
        ldd   #Ani_link_walk_up
        std   anim,u   
        cmpx  glb_vp_y_min 
        bhi   @c
        bra   Stall        
@c      stx   y_pos,u
        bra   TestBtn
TestDown
        bita  #c1_button_down_mask
        beq   Stall   
        ldx   y_pos,u
        leax  2,x
        ldd   #Ani_link_walk_down
        std   anim,u          
        cmpx  glb_vp_y_max 
        blo   @d
        bra   Stall        
@d      stx   y_pos,u    
        bra   TestBtn        
Stall
        lda   #0                            
        sta   anim_frame,u                    
TestBtn
        ;bitb  #c1_button_A_mask
        ;beq   SetAutoScroll
        ;lda   glb_Next_Game_Mode
        ;sta   GameMode
        ;lda   #$FF
        ;sta   ChangeGameMode

SetAutoScroll
        ldd   <glb_camera_y_pos
        addd  #8+16+12   ; Link sprite height is supposed 25, sprite is centered, so add 25/2
        cmpd  y_pos,u
        blo   @a
        ldd   #Ani_link_walk_up
        cmpd  anim,u
        bne   @a          
        lda   #scroll_state_up
        ldx   #8                    ; auto scroll nb frames        
        ldy   #$1000                ; auto scroll nb pixels by frame                
        bra   @scrl
@a      addd  #160-24
        cmpd  y_pos,u
        bhi   @b
        ldd   #Ani_link_walk_down
        cmpd  anim,u
        bne   @b
        lda   #scroll_state_down
        ldx   #8                    ; auto scroll nb frames        
        ldy   #$1000                ; auto scroll nb pixels by frame                
        bra   @scrl
@b      ldd   <glb_camera_x_pos
        addd  #16+8+5  ; Link sprite width is supposed 11, sprite is centered, so add 11/2
        cmpd  x_pos,u
        blo   @c
        ldd   #Ani_link_walk_side
        cmpd  anim,u
        bne   @c                    
        lda   #scroll_state_left
        ldx   #12                   ; auto scroll nb frames        
        ldy   #$0800                ; auto scroll nb pixels by frame                
        bra   @scrl
@c      addd  #112-10 
        cmpd  x_pos,u
        bhi   @exit
        ldd   #Ani_link_walk_side
        cmpd  anim,u
        bne   @exit            
        lda   #scroll_state_right        
        ldx   #12                   ; auto scroll nb frames        
        ldy   #$0800                ; auto scroll nb pixels by frame        
@scrl   sta   glb_auto_scroll_state
        stx   glb_auto_scroll_frames
        sty   glb_auto_scroll_step
        inc   routine,u
@exit   jsr   AnimateSprite   
        jmp   DisplaySprite
        
Stop
        tst   glb_auto_scroll_state
        bne   @a
        dec   routine,u
        lbra  Live
@a      jmp   DisplaySprite
