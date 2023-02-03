; ---------------------------------------------------------------------------
; Object - Weapon20
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------
        INCLUDE "./engine/macros.asm"
Weapon20
        lda   routine,u
        asla
        ldx   #Weapon20_Routines
        jmp   [a,x]
Weapon20_Routines
        fdb   Init
        fdb   Live
Init
        ldd   #Ani_weapon20
        std   anim,u
        ldb   #$04
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u
        inc   routine,u
Live
        ldd   y_pos,u
        subd  #7
        std   y_pos,u
        subd  glb_camera_y_pos
        cmpd  #15 ; img height/2
        bge   Anim
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
