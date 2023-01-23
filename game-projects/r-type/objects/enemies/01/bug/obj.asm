; ---------------------------------------------------------------------------
; Object
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"

amplitude equ ext_variables ; current amplitude
amplitude_max equ 60       ; maximum amplitude before direction change

Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Init
        fdb   LiveUp
        fdb   LiveDown

Init
        ldb   #6
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u
        ldd   #amplitude_max
        std   amplitude,u
        ldd   #$-A0
        std   x_vel,u
        lda   subtype,u
        sta   routine,u
        cmpa  #1
        bne   >
        ldd   #Ani_bug_to_up
        std   anim,u
        ldd   #$-A0
        std   y_vel,u
        bra   Object
!       ldd   #Ani_bug_to_down
        std   anim,u
        ldd   #$A0
        std   y_vel,u
        bra   Object

LiveUp
        ldd   amplitude,u
        subd  Vint_Main_runcount_w
        std   amplitude,u
        bpl   CheckEOL
        inc   routine,u
        ldd   #amplitude_max
        std   amplitude,u
        ldd   #Ani_bug_up_to_down
        std   anim,u
        ldd   #$A0
        std   y_vel,u

LiveDown
        ldd   amplitude,u
        subd  Vint_Main_runcount_w
        std   amplitude,u
        bpl   CheckEOL
        dec   routine,u
        ldd   #amplitude_max
        std   amplitude,u
        ldd   #Ani_bug_down_to_up
        std   anim,u
        ldd   #$-A0
        std   y_vel,u
        bra   LiveUp

CheckEOL
        ldd   x_pos,u
        cmpd  glb_camera_x_pos
        ble   >
        jsr   AnimateSpriteSync
        jsr   ObjectMoveSync
        jmp   DisplaySprite
!       jmp   DeleteObject