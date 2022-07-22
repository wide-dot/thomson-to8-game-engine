; ---------------------------------------------------------------------------
; Object - Ply
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm" 

Ply
        lda   routine,u
        asla
        ldx   #Ply_Routines
        jmp   [a,x]

Ply_Routines
        fdb   Init      
        fdb   Live     
Init
        ldd   #Ani_player_run
        std   anim,u
        ldb   #$04
        stb   priority,u
        ldd   #$0079-screen_left
        std   x_pos,u
        ldd   #$0080-screen_top
        std   y_pos,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask|render_overlay_mask      
        sta   render_flags,u        
        inc   routine,u
        rts
        
Live
        ldd   x_pos,u
	addd  #8
        std   x_pos,u               ; move player 8px to the right
        lda   #scroll_state_right        
        ldx   #1                    ; auto scroll nb frames        
        ldy   #$0800                ; auto scroll nb pixels by frame        
@scrl   sta   glb_auto_scroll_state
        stx   glb_auto_scroll_frames
        sty   glb_auto_scroll_step
@exit   jsr   AnimateSprite   
        jmp   DisplaySprite
