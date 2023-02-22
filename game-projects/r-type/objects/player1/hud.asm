; ---------------------------------------------------------------------------
; Object - Hud
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"

Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Init
        fdb   Live

Init
        ldd   #Img_Hud
        std   image_set,u
        ldb   #3
        stb   priority,u
        lda   render_flags,u
        anda  #255-8
        sta   render_flags,u
        ldd   #0
        std   x_pos,U
        ldd   #168
        std   y_pos,U
        inc   routine,u
Live      
        jmp   DisplaySprite