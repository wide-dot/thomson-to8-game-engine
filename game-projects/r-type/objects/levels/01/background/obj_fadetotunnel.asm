; ---------------------------------------------------------------------------
; Object
;
; input REG : [u] pointer to Object Status Table (OST)
; ---------
;
; ---------------------------------------------------------------------------

        INCLUDE "./engine/macros.asm"
        INCLUDE "./engine/objects/palette/fade/fade.equ"

Object
        lda   routine,u
        asla
        ldx   #Routines
        jmp   [a,x]

Routines
        fdb   Init
        fdb   Live
        fdb   AlreadyDeleted

Init
        ldx   #palettefade
        clr   routine,x
        ldd   Pal_current
        std   o_fade_src,x
        ldy   #Pal_tunnel
        lda   subtype,u
        beq   >
        ldy   #Pal_game
!
        sty   o_fade_dst,x
        lda   #6
        sta   o_fade_wait,x
        ldd   #Palette_FadeCallback
        std   o_fade_callback,x
        inc   routine,u
        rts
Live
        ldx   #palettefade             ; yes check palette fade
        lda   routine,x                ; is palette fade over ?
        cmpa  #o_fade_routine_idle
        bne   >
        rts        
!       inc   routine,u
        jmp   DeleteObject
AlreadyDeleted
        rts