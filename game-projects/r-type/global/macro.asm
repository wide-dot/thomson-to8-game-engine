MUSIC_NO_LOOP   EQU 0
MUSIC_LOOP      EQU 1

_MusicInit_objvgc MACRO
        jsr   IrqOff
        lda   \1
        ldy   \3
        ldb   \2 ; should be placed just before the jsr
        jsr   ,x
        jsr   IrqOn
        ENDM

_MusicInit_objymm MACRO
        jsr   IrqOff
        lda   \1
        ldy   \3
        ldb   \2 ; should be placed just before the jsr
        jsr   ,x
        jsr   IrqOn
        ENDM

_MusicFrame_objvgc MACRO
        ldb   #$80 ; should be placed just before the jsr
        jsr   ,x
        ENDM

_MusicFrame_objymm MACRO
        ldb   #$80 ; should be placed just before the jsr
        jsr   ,x
        ENDM