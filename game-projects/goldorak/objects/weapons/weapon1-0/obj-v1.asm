
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
        ldd   #Ani_weapon10
        std   anim,u
        ldb   #$03
        stb   priority,u
        ldd   #80
        std   x_pos,u
        ldd   #100
        std   y_pos,u

*        ldd   #48
*        std   glb_camera_x_offset
*        ldd   #28
*        std   glb_camera_y_offset

        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u
        inc   routine,u

        rts

Live
        ldd   y_pos,u
        subd  #5
        std   y_pos,u

        cmpd #0
        bgt Anim
        jmp   UnloadObject_u
        *ldd   #100
        *std   y_pos,u


Anim
        jsr   AnimateSprite
*        jsr   ObjectMove
        jmp   DisplaySprite


*************
* variables
*************


*************
* static params
*************
