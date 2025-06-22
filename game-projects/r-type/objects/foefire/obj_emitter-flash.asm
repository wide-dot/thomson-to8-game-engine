; ---------------------------------------------------------------------------
; Object
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"

parentaddr      equ ext_variables   ; 2 bytes

Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Init
        fdb   Live
        fdb   DieScantFireBall
        fdb   AlreadyDeleted

Init
        ldd   #Ani_emitter_flash_left
        std   anim,u
        lda   subtype,u
        beq   >
        ldd   #Ani_emitter_flash_right
        std   anim,u
!
        ldb   #3
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u
        inc   routine,u

Live
        ldx   parentaddr,u
        ldd   x_pos,x
        addd  ext_variables+16,x
        std   x_pos,u
        ldd   y_pos,x
        std   y_pos,u

        jsr   AnimateSpriteSync
        jsr   ObjectMoveSync
        jmp   DisplaySprite

DieScantFireBall  
        inc   routine,u
        jmp   DeleteObject
AlreadyDeleted
        rts