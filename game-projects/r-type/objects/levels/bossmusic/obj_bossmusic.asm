; ---------------------------------------------------------------------------
; Object
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"
        INCLUDE "./global/variables.asm"

Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Init
        fdb   AlreadyDeleted

Init
        lda   #1
        sta   NEXT_GAME_MODE

        inc   routine,u
        jmp   DeleteObject
AlreadyDeleted
        rts


