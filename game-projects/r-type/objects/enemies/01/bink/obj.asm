; ---------------------------------------------------------------------------
; Object
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; Bink subtype :
;
;       Bit 1 : (Shooting timer) 0 => Shoots early, 1=> Shoot late
;       Bit 2 : (Unused - Shoot frequency) 0 => Shoots fast, 1=> Shoots slow
;       Bit 3-4 :
;             0 -> horizontal
;             1 -> 30% angle (from horizon)
;             2 -> 60% angle (from horizon)
;             3 -> vertical
;       Bit 5 : 0 => kill tracking OFF, 1 => kill tracking ON
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"

shoottiming       equ ext_variables
shoottiming_value equ ext_variables+2
shootnoshoot      equ ext_variables+4
shootdirection    equ ext_variables+5

Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Init
        fdb   Live

Init
        ldd   #Ani_bink_left
        std   anim,u
        ldb   #6
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u
        ldd   #$-40
        std   x_vel,u
        inc   routine,u
        lda   subtype,u

        bita  #$01 ; Shoot or no shoot
        bne   >
        clr   shootnoshoot,u ; No shoot, can skip the end about shooting details
        bra   Live
!
        ldb   #1
        stb   shootnoshoot,u

        ldx   #120
        bita  #$02 ; Starts shooting late or early ?
        beq   >
        ldx   #240  ; Starts late
!
        stx   shoottiming,u

        ; This is currently unused, hence set at "less frequently" by default (according to findings on R-Type Dimensions)
        ;ldx   #60  ; Shoots more frequently or less
        ;bita  #$04
        ;beq   >
        ldx   #120  ; Less frequently
;!
        stx   shoottiming_value,u

        asra
        asra
        asra
        anda  #7
        sta   shootdirection,u


Live
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
