* ---------------------------------------------------------------------------
* PalCycling
* ----------
* palette cycling of first 3 colors in Pal_current
*
* input REG : [none]
* reset REG : [d,x,u]
*
* feature request - add parameters for color position and nb of colors
*
* ---------------------------------------------------------------------------

PalCyc_frames      fcb 0 ; countdown variable
PalCyc_frames_init fcb 0 ; nb of frames to wait for a refresh

        setdp $E7
PalCycling
 	dec   PalCyc_frames
	bne   >
	lda   PalCyc_frames_init
	sta   PalCyc_frames
	clr   PalRefresh
	ldx   Pal_current
	ldu   4,x
	ldd   2,x
	std   4,x
	ldd   ,x
	std   2,x
	stu   ,x
!       jmp   PalUpdateNow

        setdp dp/256