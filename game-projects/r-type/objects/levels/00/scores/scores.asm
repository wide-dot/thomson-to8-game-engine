
; ---------------------------------------------------------------------------
; Object - scores
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
	lda   #4
	sta   priority,u
        lda   subtype,u
        asla
        ldx   #scoreimages
        ldx   a,x
	stx   image_set,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u
        inc   routine,u
Live
	lda   subtype,u
	anda  #$80
	bne   >
        jmp   DisplaySprite
!
        rts

scoreimages     fdb Img_number_01
                fdb Img_number_02
		fdb Img_number_03
		fdb Img_number_04
		fdb Img_number_05
		fdb Img_number_06
		fdb Img_number_07
		fdb Img_number_08
		fdb Img_number_09
		fdb Img_number_10
