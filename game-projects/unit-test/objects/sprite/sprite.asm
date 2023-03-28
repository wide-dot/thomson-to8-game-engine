
; ---------------------------------------------------------------------------
; Object - Logo_R
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
        ldx   #obj_images
        ldb   subtype,u
        andb  #%00001111
        aslb
        ldd   b,x
        std   image_set,u

        clra
        ldb   subtype,u
        asrb
        asrb
        asrb
        asrb
        addd  x_pos,u  
        std   x_pos,u  
        
        ldb   #1
        stb   priority,u
        lda   render_flags,u
        ora   #render_playfieldcoord_mask
        sta   render_flags,u
        inc   routine,u
Live
        jmp   DisplaySprite

obj_images
        fdb   Img_1
        fdb   Img_2
        fdb   Img_3
        fdb   Img_4
        fdb   Img_5
        fdb   Img_6
        fdb   Img_7
        fdb   Img_8
        fdb   Img_9
        fdb   Img_10
        fdb   Img_11
        fdb   Img_12
        fdb   Img_13
        fdb   Img_14
        fdb   Img_15
        fdb   Img_16