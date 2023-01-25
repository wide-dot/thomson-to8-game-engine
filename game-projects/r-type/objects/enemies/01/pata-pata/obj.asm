; ---------------------------------------------------------------------------
; Object
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"

amplitude         equ ext_variables ; current amplitude
shoottiming       equ ext_variables+2
amplitude_max     equ 40        ; maximum amplitude before direction change
shoottiming_value equ 80


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
        ldd   #Ani_patapata
        std   anim,u
        ldb   #6
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u
        ldd   #amplitude_max
        std   amplitude,u
        ldd   #shoottiming_value
        std   shoottiming,u
        ldd   #$-A0
        std   x_vel,u
        lda   subtype,u
        anda   #$01
        inca
        sta   routine,u
        cmpa  #1
        bne   >
        ldd   #$-A0
        std   y_vel,u
        bra   Object
!       ldd   #$A0
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
        ldd   #$-A0
        std   y_vel,u
        bra   LiveUp

CheckEOL
        ldd   shoottiming,u
        subd  Vint_Main_runcount_w
        std   shoottiming,u
        bpl   @noshoot
        ldd   #shoottiming_value
        std   shoottiming,u
        jsr   LoadObject_x ; PatapataShoot
        beq   @noshoot
        lda   #ObjID_foefire
        sta   id,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        std   y_pos,x
@noshoot
        ldd   x_pos,u
        cmpd  glb_camera_x_pos
        ble   >
        jsr   AnimateSpriteSync
        jsr   ObjectMoveSync
        jmp   DisplaySprite
!       jmp   DeleteObject

        