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
shootdirection    equ ext_variables+4
shootyesno        equ ext_variables+5
shoottiming_value equ ext_variables+6
amplitude_max     equ 40
shootingtiming_value equ 80



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
        ldd   #$-A0
        std   x_vel,u
        ldd   #amplitude_max
        std   amplitude,u

        ldd   #$-A0     
        std   y_vel,u
        inc   routine,u

        lda    subtype,u
        bita   #$01
        bne >
        negb             ; Down
        std   y_vel+1,u
        clr   y_vel,u
        inc   routine,u
!        

        ;ldd    #$80
        ;std    shoottiming,u
        ;std    shoottiming_value,u

        ldb   #$80
        clr   shoottiming,u
        clr   shoottiming_value,u
        stb   shoottiming+1,u
        stb   shoottiming_value+1,u
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
        ldd   x_pos,u
        cmpd  glb_camera_x_pos
        ble   >

        ldd   shoottiming,u
        subd  Vint_Main_runcount_w
        std   shoottiming,u
        bpl   Patapatanoshoot
        ldd   shoottiming_value,u
        std   shoottiming,u
        jsr   LoadObject_x ; PatapataShoot
        beq   Patapatanoshoot
        lda   #ObjID_foefire
        sta   id,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        std   y_pos,x

        ;ldx   #Patapatashoottable
        ;clra
Patapatanoshoot
        jsr   AnimateSpriteSync
        jsr   ObjectMoveSync
        jmp   DisplaySprite
!       jmp   DeleteObject

Patapatashoottable
        fcb $120
        fcb $100
        fcb $80
        fcb $0
        fcb $80
        fcb $100

        