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
        fdb   PStaffRocketLeftExplosion
        fdb   PStaffRocketDestroy
        fdb   PStaffRocketRight
        fdb   PStaffRocketRightExplosion
        fdb   PStaffRocketDestroy

Init
        ldd   #Ani_pstaff_rocket_left
        std   anim,u
        ldb   #6
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u
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

PStaffRocketLeftExplosion
        ldd   x_pos,u
        cmpd  glb_camera_x_pos
        ble   >
        jsr   AnimateSpriteSync
        jmp   DisplaySprite


PStaffRocketRight
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

PStaffRocketRightExplosion
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
        fdb -$0025,-$0040
        fdb -$0040,-$000A
        * horizontal
        fdb -$0080,-$0000
        * descending and turning back
        fdb -$0040,$000A
        fdb -$0025,$0040
        fdb -$0010,$00A0
        * straight down
        fdb $0000,$01FF
        fdb $0000,$01FF
        fdb $0000,$01FF
        fdb $0000,$01FF
        fdb $0000,$01FF       
        
