; ---------------------------------------------------------------------------
; Object - Back
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; full screen Background
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"

Back
        lda   routine,u
        asla
        ldx   #Back_Routines
        jmp   [a,x]

Back_Routines
        fdb   Back_Init
        fdb   Back_Main

Back_Init
        ldb   #$08
        stb   priority,u

        ldd   #$7F7F
        std   xy_pixel,u

        ldd   #Ani_Back
        std   anim,u

        jsr   IrqInit
        ldd   #UserIRQ
        std   Irq_user_routine
        lda   #255                     ; set sync out of display (VBL)
        ldx   #Irq_one_frame
        jsr   IrqSync
        jsr   IrqOn 

        inc   routine,u

Back_Main
        jsr   AnimateSprite
        jmp   DisplaySprite
