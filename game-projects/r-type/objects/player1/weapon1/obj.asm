
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
        addd  #2
        std   y_pos,u

        ldd   #Img_weapon_1
        std   image_set,u
        ldb   #2
        stb   priority,u

        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u
        inc   routine,u

Live
        lda   #4
        ldb   Vint_Main_runcount
        mul
        addd  x_pos,u
        std   x_pos,u
        subd  glb_camera_x_pos
        cmpd  #160-8/2 ; img width/2
        ble   >
        jmp   DeleteObject
!       jmp   DisplaySprite


*************
* variables
*************


*************
* static params
*************
