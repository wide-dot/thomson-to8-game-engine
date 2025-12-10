_ymm.processFrame MACRO
        ldb   ymm.command
        jsr   ,x
        ENDM

_ymm.play MACRO
        lda   #ymm.command.PLAY
        sta   ymm.command
        ENDM

_ymm.stop MACRO
        lda   #ymm.command.STOP
        sta   ymm.command
        ENDM

_ymm.restart MACRO
        lda   #ymm.command.RESTART
        sta   ymm.command
        ENDM