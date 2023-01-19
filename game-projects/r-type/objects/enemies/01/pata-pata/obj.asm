; ---------------------------------------------------------------------------
; Object
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"

amplitude equ ext_variables ; current amplitude
amplitude_max equ 20        ; maximum amplitude before direction change

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
        lda   #amplitude_max
        sta   amplitude,u
        lda   subtype,u
        sta   routine,u
        bra   Object

LiveUp
        dec   amplitude,u
        beq   >
        ldd   y_pos,u
        subd  Vint_Main_runcount_w
        std   y_pos,u
        bra   CheckEOL
!       inc   routine,u
        lda   #amplitude_max
        sta   amplitude,u

LiveDown
        dec   amplitude,u
        beq   >
        ldd   y_pos,u
        addd  Vint_Main_runcount_w
        std   y_pos,u
        bra   CheckEOL
!       dec   routine,u
        lda   #amplitude_max
        sta   amplitude,u
        bra   LiveUp

CheckEOL
        ldd   x_pos,u
        subd  Vint_Main_runcount_w
        std   x_pos,u
        cmpd  glb_camera_x_pos
        ble   >
        jsr   AnimateSpriteSync
        jmp   DisplaySprite
!       jmp   DeleteObject