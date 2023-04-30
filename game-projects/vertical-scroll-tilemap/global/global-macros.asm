
_objectManager.new.u MACRO
    jsr   LoadObject_u
    lda   \1
    sta   id,u
    ENDM

_objectManager.new.x MACRO
    jsr   LoadObject_x
    lda   \1
    sta   id,x
    ENDM    


_IRQ.init    MACRO
    jsr   IrqInit
    ldd   \1
    std   Irq_user_routine
    lda   \2                     
    ldx   \3
    jsr   IrqSync
    jsr   IrqOn  
    ENDM

_gameMode.init MACRO
    jsr   InitGlobals
    jsr   InitStack
    jsr   LoadAct
    lda   \1
    sta   glb_Cur_Game_Mode
    ENDM   


_palette.set MACRO
        ldd   \1
        std   Pal_current
        ENDM   

_palette.show MACRO
        clr   PalRefresh
        jsr   PalUpdateNow
        ENDM         