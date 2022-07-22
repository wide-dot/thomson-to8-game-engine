; ---------------------------------------------------------------------------
; Object - background
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; Animated full screen Background
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"

Backgrnd
        lda   routine,u
        asla
        ldx   #Backgrnd_Routines
        jmp   [a,x]

Backgrnd_Routines
        fdb   Backgrnd_Wait
        fdb   Backgrnd_Wait
        fdb   Backgrnd_Init
        fdb   Backgrnd_Main

Backgrnd_Wait
        inc   routine,u	
        rts

Backgrnd_Init

        ; Init Object
        ; --------------------------------------------
        ldb   #3
        stb   priority,u

        lda   render_flags,u
        ora   #render_overlay_mask
        sta   render_flags,u

        ldd   #$807F
        std   xy_pixel,u

        ldd   #Ani_bck_down
        std   anim,u

	inc   routine,u	

Backgrnd_Main
        jsr   AnimateSprite	
        jmp   DisplaySprite
	