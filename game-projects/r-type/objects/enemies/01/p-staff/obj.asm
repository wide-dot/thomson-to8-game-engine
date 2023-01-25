; ---------------------------------------------------------------------------
; Object
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"

mouvement equ ext_variables ; current mouvement
mouvement_max equ 180   

Onject
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Init
        fdb   WalkLeft
        fdb   ShootLeft
        fdb   WalkRight
        fdb   ShootRight

Init
        ldd   #Ani_pstaff_walk_left
        std   anim,u
        ldb   #5
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u
        ldd   #mouvement_max
        std   mouvement,u
        ldd   #-$30
        std   x_vel,u
        inc   routine,u

WalkLeft

        ldd   mouvement,u
        subd  Vint_Main_runcount_w
        std   mouvement,u
        bpl   CheckEOL
        inc   routine,u
        ldd   #mouvement_max
        std   mouvement,u
        ldd   #0
        std   x_vel,u
        ldd   #Ani_pstaff_shoot_left
        std   anim,u
        jsr   AnimateSpriteSync
        jsr   ObjectMoveSync
        jmp   DisplaySprite

ShootLeft
        lda   anim_frame,u
        cmpa  #5
        bne   SkipRocketShootLeft
        jsr   FireRocketLeft
SkipRocketShootLeft
        ldd   mouvement,u
        subd  Vint_Main_runcount_w
        std   mouvement,u
        bpl   CheckEOL
        ldd   #Ani_pstaff_walk_right
        std   anim,u
        ldd   #mouvement_max
        std   mouvement,u
        ldd   #$30
        std   x_vel,u
        inc   routine,u
        jsr   AnimateSpriteSync
        jsr   ObjectMoveSync
        jmp   DisplaySprite

CheckEOL
        ldd   x_pos,u
        cmpd  glb_camera_x_pos
        ble   >
        jsr   AnimateSpriteSync
        jsr   ObjectMoveSync
        jmp   DisplaySprite


!       jmp   DeleteObject

WalkRight

        ldd   mouvement,u
        subd  Vint_Main_runcount_w
        std   mouvement,u
        bpl   CheckEOL
        inc   routine,u
        ldd   #mouvement_max
        std   mouvement,u
        ldd   #0
        std   x_vel,u
        ldd   #Ani_pstaff_shoot_right
        std   anim,u
        jsr   AnimateSpriteSync
        jsr   ObjectMoveSync
        jmp   DisplaySprite

ShootRight
        lda   anim_frame,u
        cmpa  #$05
        bne   SkipRocketShootRight
        jsr   FireRocketRight
SkipRocketShootRight
        ldd   mouvement,u
        subd  Vint_Main_runcount_w
        std   mouvement,u
        bpl   CheckEOL
        ldd   #Ani_pstaff_walk_left
        std   anim,u
        ldd   #mouvement_max
        std   mouvement,u
        ldd   #-$30
        std   x_vel,u
        lda   #1
        sta   routine,u
        jsr   AnimateSpriteSync
        jsr   ObjectMoveSync
        jmp   DisplaySprite

FireRocketLeft

        jsr   LoadObject_x
        beq   >
        lda   #ObjID_pstaff_rocket
        sta   id,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        subd  #8
        std   y_pos,x
!       rts

FireRocketRight
        jsr   LoadObject_x
        beq   >
        lda   #ObjID_pstaff_rocket
        sta   id,x
        lda   #1
        sta   subtype,x
        ldd   x_pos,u
        std   x_pos,x
        ldd   y_pos,u
        subd  #8
        std   y_pos,x
!       rts