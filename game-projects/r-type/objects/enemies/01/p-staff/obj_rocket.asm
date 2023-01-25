; ---------------------------------------------------------------------------
; Object
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"

Onject
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Init
        fdb   PStaffRocketLeft
        fdb   PStaffRocketExplosion
        fdb   PStaffRocketDestroy
        fdb   PStaffRocketRight
        fdb   PStaffRocketExplosion
        fdb   PStaffRocketDestroy

Init
        ldb   #6
        stb   priority,u
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
        lda   #4
        sta   routine,u

PStaffRocketRight
        ldd   x_pos,u
        cmpd  glb_camera_x_pos
        ble   >
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

PStaffRocketExplosion
        ldd   x_pos,u
        cmpd  glb_camera_x_pos
        ble   >
        jsr   AnimateSpriteSync
        jmp   DisplaySprite
PStaffRocketDestroy
!       jmp   DeleteObject

        


RocketLeftTable
        fdb $0000,-$01FF
        fdb $0000,-$01FF
        fdb $0000,-$01FF
        fdb $0000,-$01FF
        fdb $0000,-$01FF
        * starts turning
        fdb -$0010,-$00A0
        fdb -$0030,-$0040
        fdb -$0080,-$000A
        * horizontal
        fdb -$0D0,-$0000
        * descending and turning back
        fdb -$0080,$000A
        fdb -$0030,$0040
        fdb -$0010,$00A0
        * straight down
        fdb $0000,$01FF
        fdb $0000,$01FF
        fdb $0000,$01FF
        fdb $0000,$01FF
        fdb $0000,$01FF       

RocketRightTable
        fdb $0000,-$01FF
        fdb $0000,-$01FF
        fdb $0000,-$01FF
        fdb $0000,-$01FF
        fdb $0000,-$01FF
        * starts turning
        fdb $0020,-$00A0
        fdb $0040,-$0040
        fdb $0080,-$000A
        * horizontal
        fdb $00160,-$0000
        * descending and turning back
        fdb $0080,$000A
        fdb $0040,$0040
        fdb $0020,$00A0
        * straight down
        fdb $0000,$01FF
        fdb $0000,$01FF
        fdb $0000,$01FF
        fdb $0000,$01FF
        fdb $0000,$01FF       
        
