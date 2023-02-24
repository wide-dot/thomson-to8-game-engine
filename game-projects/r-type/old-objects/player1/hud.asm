; ---------------------------------------------------------------------------
; Object - Hud
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"

Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Init
        fdb   Live

Init
        ldd   #Img_Hud
        std   image_set,u
        ldb   #3
        stb   priority,u
	lda   render_flags,u
        ora   #render_overlay_mask
        sta   render_flags,u 
	ldd   #$80CC
	std   xy_pixel,u
        inc   routine,u
Live      
	_breakpoint
        jmp   DisplaySprite