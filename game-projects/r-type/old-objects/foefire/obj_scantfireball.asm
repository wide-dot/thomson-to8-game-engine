; ---------------------------------------------------------------------------
; Object
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
        fdb   DieScantFireBall

Init
        ldd   #Ani_scantfireball_left
        std   anim,u
        ldb   #3
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u
        inc   routine,u

Live
        ldd   x_pos,u
        cmpd  glb_camera_x_pos
        ble   DieScantFireBall
        jsr   AnimateSpriteSync
        jsr   ObjectMoveSync
        jmp   DisplaySprite

DieScantFireBall  
        jmp   DeleteObject