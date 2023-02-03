; ---------------------------------------------------------------------------
; Object
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; Patapata subtype :
;       
;       Bit 0 : 0 => Starts up, 1 => Starts down
;       Bit 1 : 0 => Doies not shoot, 1 => Shoots
;       Bit 2 : (Shooting timer) 0 => Shoots early, 1=> Shoot late
;       Bit 3 : (Unused - Shoot frequency) 0 => Shoots fast, 1=> Shoots slow
;       Bit 4-5 :
;             0 -> horizontal
;             1 -> 30% angle (from horizon)
;             2 -> 60% angle (from horizon)
;             3 -> vertical
;       Bit 6 : 0 => kill tracking OFF, 1 => kill tracking ON
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"

amplitude         equ ext_variables ; current amplitude
shoottiming       equ ext_variables+2
shoottiming_value equ ext_variables+4
shootnoshoot      equ ext_variables+6
shootdirection    equ ext_variables+7
amplitude_max     equ 40        ; maximum amplitude before direction change



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
        ldd   #$-A0
        std   x_vel,u

        ldx   #$-A0
        inc   routine,u
        lda   subtype,u

        bita  #$01 ; Up or down ?
        beq   >
        ldx   #$A0 ; This is down
        inc   routine,u
!
        stx   y_vel,u

        bita  #$02 ; Shoot or no shoot
        bne   >
        clr   shootnoshoot,u ; No shoot, can skip the end about shooting details
        bra   Object
!
        ldb   #1
        stb   shootnoshoot,u

        ldx   #80
        bita  #$04 ; Starts shooting late or early ?
        beq   >
        ldx   #160  ; Starts late
!
        stx   shoottiming,u

        ; This is currently unused, hence set at "less frequently" by default (according to findings on R-Type Dimensions)
        ;ldx   #40  ; Shoots more frequently or less
        ;bita  #$08
        ;beq   >
        ldx   #80  ; Less frequently
;!
        stx   shoottiming_value,u

        asra
        asra
        asra
        asra
        anda  #7
        sta   shootdirection,u

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
        lda   shootnoshoot,u
        beq   @noshoot
        ldd   shoottiming,u
        subd  Vint_Main_runcount_w
        std   shoottiming,u
        bpl   @noshoot
        ldd   shoottiming_value,u
        std   shoottiming,u
        jsr   LoadObject_x ; PatapataShoot
        beq   @noshoot
        lda   #ObjID_foefire
        sta   id,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        std   y_pos,x
        lda   shootdirection,u
        jsr   ReturnShootDirection_X
        std   x_vel,x
        lda   shootdirection,u
        jsr   ReturnShootDirection_Y
        std   y_vel,x
@noshoot
        ldd   x_pos,u
        cmpd  glb_camera_x_pos
        ble   >
        jsr   AnimateSpriteSync
        jsr   ObjectMoveSync
        jmp   DisplaySprite
!       jmp   DeleteObject
