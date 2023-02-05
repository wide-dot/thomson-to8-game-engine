
_NewManagedObject_U MACRO
    jsr   LoadObject_u
    lda   \1
    sta   id,u
    ENDM

_MusicInit_SN76489 MACRO
    ldd   \2
    ldx   \1
    orcc  \3 ; set carry (loop)
    jsr   vgc_init 
    ENDM

_MusicInit_YM2413 MACRO
    ldx   \1
    orcc  \2 ; set carry (loop)
    jsr   YVGM_PlayMusic 
    ENDM

_MusicInit_IRQ    MACRO
    jsr   IrqInit
    ldd   \1
    std   Irq_user_routine
    lda   \2                     
    ldx   \3
    jsr   IrqSync
    jsr   IrqOn  
    ENDM

_GameModeInit MACRO
    jsr   InitGlobals
    jsr   LoadAct
    jsr   InitJoypads
    ENDM   

_ObjectInitRoutines MACRO
    lda   routine,u
    asla
    ldx   \1
    jmp   [a,x]  
    ENDM   