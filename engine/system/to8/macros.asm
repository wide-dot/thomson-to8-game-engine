_system.reboot MACRO
        jsr   IrqOff
        jsr   sn_reset
        jsr   YVGM_SilenceAll
        ldd   #$A55A   ; boot signature part 1      
        std   $60FE
        lda   #$40     ; boot signature part 2
        sta   $605F
        com   $60D1    ; changing boot signature, to avoid booting to basic after a first boot to disk
        jmp   [$FFFE]
        ENDM