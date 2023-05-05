; ******************************************************
; Use with de generic game loop provided by main.asm
; date: 2023-05-05
; ******************************************************
_main.update.return MACRO
        jmp   main.update.return
 ENDM

_main.render.return MACRO
        jmp   main.render.return
 ENDM    

_main.setUpdateRoutine MACRO
        ldd #\1
        std main.routines.update
 ENDM

_main.setRenderRoutine MACRO
        ldd #\1
        std main.routines.render
 ENDM

_main.loop.run MACRO
        jmp main.loop
 ENDM 