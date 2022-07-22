********************************************************************************
* Clear memory in data area
* !!! IRQ should be disabled !!!
*
* input  REG : [x] color for 4 pixels
********************************************************************************

ClearVerticalBandLR
        tfr   x,y
        ldu   #$DF40
@a
        pshu  x
	leau  -36,U
	pshu  x,y
	leau  -36,U
	pshu  x,y
	leau  -36,U
	pshu  x,y
	leau  -36,U
	pshu  x,y
	leau  -36,U
	pshu  x,y
	leau  -36,U
	pshu  x,y
	leau  -36,U
	pshu  x,y
	leau  -36,U
	pshu  x,y
	leau  -36,U
	pshu  x,y
	leau  -36,U
	pshu  x
        cmpu  #$C000
        bne   @a
      
        ldu   #$BF40
@a
        pshu  x
	leau  -36,U
	pshu  x,y
	leau  -36,U
	pshu  x,y
	leau  -36,U
	pshu  x,y
	leau  -36,U
	pshu  x,y
	leau  -36,U
	pshu  x,y
	leau  -36,U
	pshu  x,y
	leau  -36,U
	pshu  x,y
	leau  -36,U
	pshu  x,y
	leau  -36,U
	pshu  x,y
	leau  -36,U
	pshu  x
        cmpu  #$A000
        bne   @a
	rts
