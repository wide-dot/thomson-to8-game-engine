; ---------------------------------------------------------------------------
; Object
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"
        INCLUDE "./objects/foefire/obj_emitter-flash.equ"

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
        lda   emitterFlash.delay,u
        beq   >
        dec   emitterFlash.delay,u
        rts
!

        ldd   #Ani_emitter_flash_left
        tst   subtype,u
        beq   >
        ldd   #Ani_emitter_flash_right
!       std   anim,u

        ldb   #4
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u
        inc   routine,u

Live
        ldx   emitterFlash.parent,u
        ldd   x_pos,x
        addd  emitterFlash.x_offset,u
        std   x_pos,u
        ldd   y_pos,x
        std   y_pos,u

        jsr   AnimateSpriteSync
        jsr   ObjectMoveSync
        jmp   DisplaySprite

Delete  
        inc   routine,u
        jmp   DeleteObject
AlreadyDeleted
        rts