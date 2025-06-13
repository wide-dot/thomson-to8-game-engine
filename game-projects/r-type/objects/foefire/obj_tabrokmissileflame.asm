; ---------------------------------------------------------------------------
; Object
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/collision/macros.asm"


kill_me	equ ext_variables ; 1 byte

Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Init                                      ; 0
        fdb   Run    					; 1
        fdb   AlreadyDeleted                            ; 2

Init
	ldx   #ImagesIndex
        ldd   ,x
	std   image_set,u
	ldb   #3
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u
	inc   routine,u

Run
	lda   kill_me,u
	bne   Delete
        
	ldx   #ImagesIndex
        ldb   gfxlock.frame.count+1
        andb  #$06
	ldd   b,x
	std   image_set,u

	jmp   DisplaySprite

Delete
        lda   #2    ; AlreadyDeleted
        sta   routine,u
        jmp   DeleteObject

AlreadyDeleted
	rts


ImagesIndex
        fdb   Img_tabrokmissileflame_0
	fdb   Img_tabrokmissileflame_1
	fdb   Img_tabrokmissileflame_2
	fdb   Img_tabrokmissileflame_3