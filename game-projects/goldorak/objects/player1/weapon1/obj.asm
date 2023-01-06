
; ---------------------------------------------------------------------------
; Object - Weapon10
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"

Weapon10
        lda   routine,u
        asla
        ldx   #Weapon10_Routines
        jmp   [a,x]

Weapon10_Routines
        fdb   Init
        fdb   Live

Init
        ldd   x_pos,u
        addd  #6
        std   x_pos,u

        ldd   y_pos,u
        addd  #4
        std   y_pos,u

        ldd   #Ani_weapon_1
        std   anim,u
        ldb   #$04
        stb   priority,u

        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u
        inc   routine,u

Live
        ldd   x_pos,u
        addd  #6
        tst   glb_camera_update
        beq   >
        addd  #2
!
        std   x_pos,u
        subd  glb_camera_x_pos
        cmpd  #160-8/2 ; img height/2
        ble   Anim
        jmp   DeleteObject

Anim
        jsr   AnimateSprite
        jmp   DisplaySprite


*************
* variables
*************


*************
* static params
*************
