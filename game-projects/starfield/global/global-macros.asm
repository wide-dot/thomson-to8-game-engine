_IRQ.init MACRO
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

; Music: \1 = song data, \2 = loop flag, \3 = start position.
; The per-frame tick (YVGM_MusicFrame + vgc_update) is driven from UserIRQ,
; wired by _IRQ.init above — see game-mode/00/main.asm.
_music.init.SN76489 MACRO
    ldx   \1
    ldb   \2
    ldy   \3
    jsr   vgc_init
    ENDM

_music.init.YM2413 MACRO
    ldx   \1
    ldb   \2
    ldy   \3
    jsr   YVGM_PlayMusic
    ENDM

_palette.set MACRO
    ldd   \1
    std   Pal_current
    ENDM

_palette.show MACRO
    clr   PalRefresh
    jsr   PalUpdateNow
    ENDM
