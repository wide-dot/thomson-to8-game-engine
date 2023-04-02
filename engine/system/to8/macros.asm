_system.reboot MACRO
        jsr   IrqOff
 ifdef sn76489.reset
        jsr   sn76489.reset
 endc
 ifdef ym2413.reset
        jsr   ym2413.reset
 endc
        ldd   #$A55A   ; boot signature part 1      
        std   $60FE
        lda   #$40     ; boot signature part 2
        sta   $605F
        com   $60D1    ; changing boot signature, to avoid booting to basic after a first boot to disk
        jmp   [$FFFE]
        ENDM