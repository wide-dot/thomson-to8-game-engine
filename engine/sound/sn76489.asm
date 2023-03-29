
; Reset SN76489 sound chip to a default (silent) state
; ----------------------------------------------------

 IFNDEF sn76489.reset
sn76489.reset
        lda   #$9F
        sta   SN76489.D
vgc_port_01 equ *-1
        nop
        nop
        lda   #$BF
        sta   SN76489.D  
vgc_port_02 equ *-1  
        nop
        nop
        lda   #$DF
        sta   SN76489.D
vgc_port_03 equ *-1
        nop
        nop
        lda   #$FF
        sta   SN76489.D  
vgc_port_04 equ *-1
	rts
 ENDC