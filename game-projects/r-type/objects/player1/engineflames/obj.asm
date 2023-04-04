
; ---------------------------------------------------------------------------
; Object - Weapon1
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/collision/macros.asm"

Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Init
        fdb   Live
        fdb   Delete
        fdb   AlreadyDeleted

Init
        ldy   #Ani_engineflames_init
        lda   subtype,u
        beq   >
        ldy   #Ani_engineflames_speed
!
        sty   anim,u
        ldb   #3
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u
        inc   routine,u

Live
        ldd   player1+x_pos
        subd  #12
        std   x_pos,u
        ldd   player1+y_pos
        std   y_pos,u

        jsr   AnimateSpriteSync
        jmp   DisplaySprite
Delete
        inc   routine,u
        jmp   DeleteObject
AlreadyDeleted
        rts