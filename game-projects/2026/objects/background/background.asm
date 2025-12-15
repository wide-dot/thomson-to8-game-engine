; ---------------------------------------------------------------------------
; Object - Background
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; Animated full screen Background
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"

Background
        lda   routine,u
        asla
        ldx   #Background_Routines
        jmp   [a,x]

Background_Routines
        fdb   Background_Init
        fdb   Background_Main

Background_Init
        ldb   #$08
        stb   priority,u

        lda   render_flags,u
        ora   #render_overlay_mask
        sta   render_flags,u

        ldd   #$7F7F
        std   xy_pixel,u

        ldd   #Ani_Background
        std   anim,u

        inc   routine,u

Background_Main
        jsr   AnimateSprite
        jmp   DisplaySprite
