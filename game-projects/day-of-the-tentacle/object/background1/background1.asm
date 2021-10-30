; ---------------------------------------------------------------------------
; Object - background
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; Animated full screen Background
;
; ---------------------------------------------------------------------------

        INCLUDE "./Engine/Macros.asm"

Backgrnd
        lda   routine,u
        asla
        ldx   #Backgrnd_Routines
        jmp   [a,x]

Backgrnd_Routines
        fdb   Backgrnd_Back1
        fdb   Backgrnd_Back2	
        fdb   Backgrnd_Init
        fdb   Backgrnd_Main

Backgrnd_Back1
        ldb   #3
        stb   priority,u

        lda   render_flags,u
        ora   #render_overlay_mask
        sta   render_flags,u

        ldd   #$807F
        std   xy_pixel,u

        ldd   #Img_back1
        std   image_set,u

	inc   routine,u
        jmp   DisplaySprite	

Backgrnd_Back2
        ldd   #Img_back2
        std   image_set,u

	inc   routine,u
        jmp   DisplaySprite	

Backgrnd_Init	
        ldd   #Ani_bck_up
        std   anim,u
	inc   routine,u

Backgrnd_Main
        jsr   AnimateSprite	
        jmp   DisplaySprite
	