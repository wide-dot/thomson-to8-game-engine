ORG 0

INCLUDE "lib/exomiser.h.asm"

ORG &1900
.start

INCLUDE "lib/exomiser.asm"
INCLUDE "lib/vgmplayer.asm"
INCLUDE "lib/irq.asm"


.event_handler
{
	php
	cmp #4
	bne not_vsync

	\\ Preserve registers
	pha:txa:pha:tya:pha

	; prevent re-entry
	lda re_entrant
	bne skip_update
	inc re_entrant


	\\ Poll the music player
	jsr vgm_poll_player

	dec re_entrant
.skip_update

	\\ Restore registers
	pla:tay:pla:tax:pla

	\\ Return
    .not_vsync
	plp
	rts
.re_entrant EQUB 0
}


.main
{


    LDX #LO(&3000)
	LDY #HI(&3000)
	JSR	vgm_init_stream


    \\ Start our event driven fx
    ldx #LO(event_handler)
    ldy #HI(event_handler)
    JSR start_eventv
    rts
}

ORG &3000
INCBIN "music/vgm_out/Chris Kelly - SMS Power 15th Anniversary Competitions - Collision Chaos.bin.exo"
.end

SAVE "Main", start, end, main


PUTFILE "music/vgm_out/BotB 16433 Slimeball - Fluid Dynamics.bin.exo", "V.FLUID", &3000, &3000
PUTFILE "music/vgm_out/ne7-magic_beansmaster_system_psg.bin.exo", "V.MAGIC", &3000, &3000
PUTFILE "music/vgm_out/Chris Kelly - SMS Power 15th Anniversary Competitions - Collision Chaos.bin.exo", "V.CHAOS", &3000, &3000


PRINT "Vgm Player Size = ", (vgm_player_end-vgm_player_start)
PRINT "Exo Compressor Size = ", (exo_end-exo_start)
