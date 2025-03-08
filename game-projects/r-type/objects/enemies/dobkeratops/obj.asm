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
        ldx   b,x
        stx   image_set,u

        ; init sprite position
        ldd   #1507
        std   x_pos,u
        ldd   #100
        std   y_pos,u

        ; display priority
        ldb   subtype,u
        stb   priority,u

        ; display settings
        lda   #render_playfieldcoord_mask|render_xloop_mask
        ldb   subtype+1,u
        cmpb  #7
        blo   >
        ora   #render_overlay_mask
!       sta   render_flags,u

        inc   routine,u
        jmp   DisplaySprite

SubImages
        fdb   Img_dobkeratops_eye00
        fdb   Img_dobkeratops_eye01
        fdb   Img_dobkeratops_eye10
        fdb   Img_dobkeratops_eye20
        fdb   Img_dobkeratops_eye30
        fdb   Img_dobkeratops_eye31
        fdb   Img_dobkeratops_eye32

        fdb   Img_dobkeratops_alienN0
        fdb   Img_dobkeratops_alienN1
        fdb   Img_dobkeratops_alienN2
        fdb   Img_dobkeratops_alienN3

        fdb   Img_dobkeratops_erase00
        fdb   Img_dobkeratops_erase01
        fdb   Img_dobkeratops_erase02
        fdb   Img_dobkeratops_erase10
        fdb   Img_dobkeratops_erase11
        fdb   Img_dobkeratops_erase20
        fdb   Img_dobkeratops_erase21
        fdb   Img_dobkeratops_erase30
        fdb   Img_dobkeratops_erase31
        fdb   Img_dobkeratops_erase32

        fdb   Img_dobkeratops_alien0
        fdb   Img_dobkeratops_alien1
        fdb   Img_dobkeratops_alien2
        fdb   Img_dobkeratops_alien3

Run
        jmp   DisplaySprite

MoveOut
        jmp   DisplaySprite



