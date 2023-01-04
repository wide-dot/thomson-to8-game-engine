



\ ******************************************************************
\ *	Event Vector Routines
\ ******************************************************************

\\ System vars
.old_eventv				SKIP 2

.start_eventv				; new event handler in X,Y
{
	\\ Set new Event handler
	sei
	lda &220 ; EVENTV
	sta old_eventv
	lda &221
	sta old_eventv+1

	stx &220
	sty &221
	cli

	\\ Enable VSYNC event.
	lda #14
	ldx #4
	jsr &fff4
	rts
}
	
.stop_eventv
{
	\\ Disable VSYNC event.
	lda #13
	ldx #4
	jsr &fff4

	\\ Reset old Event handler
	sei
	lda old_eventv
	sta &220
	lda old_eventv+1
	sta &221
	cli 
	rts
}
