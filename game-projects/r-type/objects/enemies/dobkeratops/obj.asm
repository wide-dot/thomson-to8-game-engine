; ---------------------------------------------------------------------------
; Object
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
        fdb   Run
        fdb   MoveOut

Init
        ; setup image
        ldx   #SubImages
        ldb   subtype+1,u
        aslb
        ldd   b,x
        std   image_set,u

        ; init sprite position
        lda   #16 ; sprite width
        ldb   subtype+1,u
        mul
        addd  #1491
        std   x_pos,u
        ldd   #100
        std   y_pos,u

        ; display priority
        ldb   #8
        stb   priority,u

        ; display settings
        lda   #render_playfieldcoord_mask|render_overlay_mask|render_xloop_mask
        sta   render_flags,u

        inc   routine,u
        jmp   DisplaySprite

SubImages
        fdb   Img_dobkeratops_0
        fdb   Img_dobkeratops_1
        fdb   Img_dobkeratops_2
        fdb   Img_dobkeratops_3

Run
        jmp   DisplaySprite

MoveOut
        jmp   DisplaySprite



