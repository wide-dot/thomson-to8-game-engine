; ---------------------------------------------------------------------------
; Object
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"

mouvement equ ext_variables ; current amplitude
mouvement_max equ 100   

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
        ldb   #6
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u
        ldd   #mouvement_max
        std   mouvement,u
        ldd   #$-30
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
        clr   x_vel,u
        ldd   #Ani_pstaff_shoot_left
        std   anim,u
        jsr   AnimateSpriteSync
        jsr   ObjectMoveSync
        jmp   DisplaySprite

ShootLeft
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

WalkRight

        ldd   mouvement,u
        subd  Vint_Main_runcount_w
        std   mouvement,u
        bpl   CheckEOL
        inc   routine,u
        ldd   #mouvement_max
        std   mouvement,u
        clr   x_vel,u
        ldd   #Ani_pstaff_shoot_right
        std   anim,u
        jsr   AnimateSpriteSync
        jsr   ObjectMoveSync
        jmp   DisplaySprite

ShootRight
        ldd   mouvement,u
        subd  Vint_Main_runcount_w
        std   mouvement,u
        bpl   CheckEOL
        lda   #01
        sta   routine,u
        ldd   #Ani_pstaff_walk_left
        std   anim,u
        ldd   #mouvement_max
        std   mouvement,u
        ldd   #-$30
        std   x_vel,u
        inc   routine,u
        jsr   AnimateSpriteSync
        jsr   ObjectMoveSync
        jmp   DisplaySprite

!       jmp   DeleteObject
