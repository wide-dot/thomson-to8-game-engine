
; Reset YM2413 sound chip to a default (silent) state
; ----------------------------------------------------

 IFNDEF ym2413.reset
ym2413.reset
        ldd   #$200E
        stb   YM2413.A
        nop                            ; (wait of 2 cycles)
        ldb   #0                       ; (wait of 2 cycles)
        sta   YM2413.D                ; note off for all drums     
        lda   #$20                     ; (wait of 2 cycles)
        brn   *                        ; (wait of 3 cycles)
@c      exg   a,b                      ; (wait of 8 cycles)                                      
        exg   a,b                      ; (wait of 8 cycles)                                      
        sta   YM2413.A
        nop
        inca
        stb   YM2413.D
        cmpa  #$29                     ; (wait of 2 cycles)
        bne   @c                       ; (wait of 3 cycles)
        rts  
 ENDC