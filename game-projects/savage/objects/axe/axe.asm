; ---------------------------------------------------------------------------
; Object - Axe
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm" 

Axe
        lda   routine,u
        asla
        ldx   #Axe_Routines
        jmp   [a,x]

Axe_Routines
        fdb   Init      
        fdb   Live     
Init
        ldd   #Ani_axe
        std   anim,u
        ldb   #$02
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask|render_overlay_mask        
        sta   render_flags,u        
        inc   routine,u
        rts
        
Live
        ldd   x_pos,u
	addd  #8
        std   x_pos,u               ; move 8px to the right
        jsr   AnimateSprite   
        jmp   DisplaySprite
