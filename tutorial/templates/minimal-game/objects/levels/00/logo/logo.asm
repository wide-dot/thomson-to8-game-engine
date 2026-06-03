
; ---------------------------------------------------------------------------
; Object - Logo_R
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
        lda   subtype,u
        inca
        sta   priority,u
        deca
        asla
        ldx   #logoimages
        ldx   a,x
        stx   image_set,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u
        inc   routine,u
Live
	jsr   ObjectMoveSync
        jmp   DisplaySprite
AlreadyDeleted
        rts

logoimages      fdb Img_logo_tm
                fdb Img_logo_r
                fdb Img_logo_dot
                fdb Img_logo_t
                fdb Img_logo_y
                fdb Img_logo_p
                fdb Img_logo_e
