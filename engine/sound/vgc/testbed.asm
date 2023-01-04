;******************************************************************
; 6502 BBC Micro Compressed VGM (VGC) Music Player
; By Simon Morris
; https://github.com/simondotm/vgm-player-bbc
; https://github.com/simondotm/vgm-packer
;******************************************************************


; Allocate vars in ZP
.zp_start
ORG &70
GUARD &8f


;----------------------------------------------------------------------------------------------------------
; Common code headers
;----------------------------------------------------------------------------------------------------------
; Include common code headers here - these can declare ZP vars from the pool using SKIP...

INCLUDE "lib/vgcplayer_config.h.asm"
INCLUDE "lib/vgcplayer.h.asm"
INCLUDE "lib/exomiser.h.asm"

.zp_end


\ ******************************************************************
\ *	Utility code - always memory resident
\ ******************************************************************

ORG &3000
GUARD &7c00

.vgc_test_start

;----------------------------


;-------------------------------------------
; main VGC TEST
;-------------------------------------------




ALIGN 256
.performance_test
{

    ; initialize the vgm player with a vgc data stream
    lda #hi(vgm_stream_buffers)
    ldx #lo(vgm_data)
    ldy #hi(vgm_data)
    clc ; clear carry to disable looping
    jsr vgm_init

.loop




    jsr vgm_update
    pha
    inc vgc_test_counter+0
    bne nohi
    inc vgc_test_counter+1
.nohi

    pla
    beq loop
    lda #67:jsr&ffee

    lda vgc_test_counter+0
    sta &70
    lda vgc_test_counter+1
    sta &71
    rts
}
.vgc_test_counter EQUW 0



ALIGN 256
.decode_bytes
    ; initialize the vgm player with a vgc data stream
    lda #hi(vgm_stream_buffers)
    ldx #lo(vgm_data)
    ldy #hi(vgm_data)
    clc ; clear carry to disable looping
    jsr vgm_init
    rts


ALIGN 256
.decode_update
    jsr vgm_update
    pha

    lda vgm_fx + 0
    sta decoded_data + 0
    lda vgm_fx + 1
    sta decoded_data + 1
    lda vgm_fx + 2
    sta decoded_data + 2
    lda vgm_fx + 3
    sta decoded_data + 3
    lda vgm_fx + 4
    sta decoded_data + 4
    lda vgm_fx + 5
    sta decoded_data + 5
    lda vgm_fx + 6
    sta decoded_data + 6
    lda vgm_fx + 7
    sta decoded_data + 7
    lda vgm_fx + 8
    sta decoded_data + 8
    lda vgm_fx + 9
    sta decoded_data + 9
    lda vgm_fx + 10
    sta decoded_data + 10

    pla
    rts

ALIGN 256
.decoded_data
SKIP 11






.decode_bytes_end

.performance_test_end

.vgm_buffer_start

; reserve space for the vgm decode buffers (8x256 = 2Kb)
ALIGN 256
.vgm_stream_buffers
    skip 256
    skip 256
    skip 256
    skip 256
    skip 256
    skip 256
    skip 256
    skip 256


.vgm_buffer_end

; include your tune of choice here, some samples provided....
.vgm_data
INCBIN "music/vgc/song_091.vgc"
;INCBIN "music/vgc/axelf.vgc"
;INCBIN "music/vgc/bbcapple.vgc"
;INCBIN "music/vgc/nd-ui.vgc"
;INCBIN "music/vgc/outruneu.vgc"
;INCBIN "music/vgc/ym_009.vgc"
;INCBIN "music/vgc/test_bbc.vgc"
;INCBIN "music/vgc/acid_demo.vgc"


; code routines

INCLUDE "lib/vgcplayer.asm"


.vgc_test_end

PRINT ~vgm_data

PRINT "PERFORMANCE TEST = ", ~performance_test

PRINT "DECODE INIT = ", ~decode_bytes
PRINT "DECODE UPDATE = ", ~decode_update
PRINT "DECODE DATA = ", ~decoded_data




SAVE "VGCTEST", vgc_test_start, vgc_test_end, performance_test
PUTBASIC "basic/dump.bas", "DUMP"
PUTBASIC "basic/perftest.bas", "TEST"


;-------------------------------------------
; main VGM TEST
;-------------------------------------------


CLEAR &3000, &7C00
ORG &3000

.vgm_test_start


.vgm_test_main
{


    LDX #LO(vgm_test_data)
	LDY #HI(vgm_test_data)
	JSR	vgm_init_stream

.loop
	jsr vgm_poll_player
	LDA vgm_player_ended    ; non zero if true

    pha
    inc vgm_test_counter+0
    bne nohi
    inc vgm_test_counter+1
.nohi

    pla
    beq loop

    lda #67:jsr&ffee

    lda vgm_test_counter+0
    sta &70
    lda vgm_test_counter+1
    sta &71

    rts
}
.vgm_test_counter EQUW 0

INCLUDE "lib/exomiser.asm"
INCLUDE "lib/vgmplayer.asm"

.vgm_test_data
INCBIN "music/vgm_out/Chris Kelly - SMS Power 15th Anniversary Competitions - Collision Chaos.bin.exo"
;PUTFILE "music/vgm_out/BotB 16433 Slimeball - Fluid Dynamics.bin.exo", "V.FLUID", &3000, &3000
;PUTFILE "music/vgm_out/ne7-magic_beansmaster_system_psg.bin.exo", "V.MAGIC", &3000, &3000
;PUTFILE "music/vgm_out/Chris Kelly - SMS Power 15th Anniversary Competitions - Collision Chaos.bin.exo", "V.CHAOS", &3000, &3000


.vgm_test_end

SAVE "VGMTEST", vgm_test_start, vgm_test_end, vgm_test_main




PRINT "Vgm Player Size = ", (vgm_player_end-vgm_player_start)
PRINT "Exo Compressor Size = ", (exo_end-exo_start)