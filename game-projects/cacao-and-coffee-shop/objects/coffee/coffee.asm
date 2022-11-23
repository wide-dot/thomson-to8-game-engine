; ---------------------------------------------------------------------------
; Object - Coffee
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; Animated full screen Background
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"

Coffee
        lda   routine,u
        asla
        ldx   #Coffee_Routines
        jmp   [a,x]

Coffee_Routines
        fdb   Coffee_Init
        fdb   Coffee_Main

Coffee_Init
        ; Init Object
        ; --------------------------------------------
        ldb   #$08
        stb   priority,u

        lda   render_flags,u
        ora   #render_overlay_mask
        sta   render_flags,u

        ldd   #$807F
        std   xy_pixel,u

        ldd   #Ani_Coffee
        std   anim,u

        ; Init Sound Driver
        ; --------------------------------------------
        jsr   PSGInit

        jsr   IrqInit
        ldd   #UserIRQ_PSG
        std   Irq_user_routine
        lda   #255                     ; set sync out of display (VBL)
        ldx   #Irq_one_frame
        jsr   IrqSync
        jsr   IrqOn 
        
        ldx   #Psg_001
        jsr   PSGPlay

        inc   routine,u

Coffee_Main
        jsr   AnimateSprite
        jmp   DisplaySprite
