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

Init
        ldd   #Ani_foefire_0
        std   anim,u
        ldb   #3
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u

        ldd   #$-B0
        std   x_vel,u
        ldd   #$0
        std   y_vel,u
        inc   routine

Live
        ldd   x_pos,u
        cmpd  glb_camera_x_pos
        ble   >
        jsr   AnimateSpriteSync
        jsr   ObjectMoveSync
        jmp   DisplaySprite
        
!       jmp   DeleteObject