; ---------------------------------------------------------------------------
; Object
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"
        INCLUDE "./objects/explosion/explosion.const.asm"

origin equ ext_variables ; missile origin

Onject
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Init
        fdb   PStaffRocketLeft
        fdb   PStaffRocketDestroy
        fdb   PStaffRocketRight
        fdb   PStaffRocketDestroy
        fdb   AlreadyDeleted

Init
        ldb   #6
        stb   priority,u
        ldd   y_pos,u
        addd  #35
        std   origin,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u
        lda   subtype,u
        bne   InitRocketRight
        ldd   #Ani_pstaff_rocket_left
        std   anim,u
        inc   routine,u

PStaffRocketLeft
        ldd   x_pos,u
        cmpd  glb_camera_x_pos
        ble   >
        ldd   y_pos,u
        cmpd  origin,u
        bgt   PStaffRocketDestroy
        lda   anim_frame,u
        asla
        asla
        ldy   #RocketLeftTable
        ldx   a,y
        stx   x_vel,u
        inca
        inca
        ldx   a,y
        stx   y_vel,u
        jsr   AnimateSpriteSync
        jsr   ObjectMoveSync
        jmp   DisplaySprite


InitRocketRight
        ldd   #Ani_pstaff_rocket_right
        std   anim,u
        lda   #3
        sta   routine,u

PStaffRocketRight
        ldd   x_pos,u
        cmpd  glb_camera_x_pos
        ble   >
        ldd   y_pos,u
        cmpd  origin,u
        bgt   PStaffRocketDestroy
        lda   anim_frame,u
        asla
        asla
        ldy   #RocketRightTable
        ldx   a,y
        stx   x_vel,u
        inca
        inca
        ldx   a,y
        stx   y_vel,u
        jsr   AnimateSpriteSync
        jsr   ObjectMoveSync
        jmp   DisplaySprite

PStaffRocketDestroy
        jsr   LoadObject_x ; Explosion
        beq   >
        _ldd   ObjID_explosion,explosion.subtype.fwk
        std   id,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        std   y_pos,x
        inc   routine,u
!       jmp   DeleteObject
AlreadyDeleted
        rts

        


RocketLeftTable
        fdb $0000,-$02FF
        fdb -$0040,-$02FF
        fdb -$0040,-$02FF
        fdb -$0040,-$02FF
        fdb -$0040,-$02FF
        * starts turning
        fdb -$0040,-$0100
        fdb -$0060,-$0050
        fdb -$0080,-$0010
        * horizontal
        fdb -$00D0,-$0000
        * descending and turning back
        fdb -$0080,$0010
        fdb -$0060,$0050
        fdb -$0040,$0100
        * straight down
        fdb -$0040,$02FF
        fdb -$0040,$02FF
        fdb -$0040,$02FF
        fdb -$0040,$02FF
        fdb $0000,$02FF       

RocketRightTable
        fdb $0000,-$02FF
        fdb $0040,-$02FF
        fdb $0040,-$02FF
        fdb $0040,-$02FF
        fdb $0040,-$02FF
        * starts turning
        fdb $0040,-$0100
        fdb $0060,-$0050
        fdb $0080,-$0010
        * horizontal
        fdb $00D0,-$0000
        * descending and turning back
        fdb $0080,$0010
        fdb $0060,$0050
        fdb $0040,$0100
        * straight down
        fdb $0040,$02FF
        fdb $0040,$02FF
        fdb $0040,$02FF
        fdb $0040,$02FF
        fdb $0040,$02FF     
        
