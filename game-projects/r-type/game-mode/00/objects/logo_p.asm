
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
        ldd   #logo_p
        std   image_set,u
        ldb   #5
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u
        inc   routine,u
Live
	jsr   ObjectMoveSync
        jmp   DisplaySprite
AlreadyDeleted
        rts