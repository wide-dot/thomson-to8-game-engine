; ---------------------------------------------------------------------------
; Object - Nindendo
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; Animated full screen Background
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"

Nindendo
        lda   routine,u
        asla
        ldx   #Nindendo_Routines
        jmp   [a,x]

Nindendo_Routines
        fdb   Nindendo_Init
        fdb   Nindendo_Main
	fdb   Nindendo_Alt2
        fdb   Nindendo_End

Nindendo_Init

        ldb   #1
        stb   priority,u

        lda   render_flags,u
        ora   #render_overlay_mask
        sta   render_flags,u

        ldd   #$80CB
        std   xy_pixel,u

        ldd   #Img_Nindendo_alt
        std   image_set,u

        ldd   #431                     ; nb of frames before palette switch
        std   ext_variables,u	
	inc   routine,u
	jmp   DisplaySprite

Nindendo_Main

        ldd   ext_variables,u
	subd  #1
	std   ext_variables,u
	beq   @a
        jmp   DisplaySprite
@a      inc   routine,u
        ldd   #Img_Nindendo
        std   image_set,u
        jmp   DisplaySprite

Nindendo_Alt2
        inc   routine,u
        jmp   DisplaySprite

Nindendo_End
        jmp   DisplaySprite