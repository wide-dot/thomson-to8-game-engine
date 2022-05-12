	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_islandWater07_0
	LEAU 922,U

	LDD #$dc0c
	LDX #$cccc
	LDY #$ffff
	PSHU D,X,Y
	LDA -4,U
	ANDA #$F0
	ORA #$0f
	STA -4,U
	LDA #$22
	LDX #$2c2d
	PSHU A,X

	LDU <glb_screen_location_1
	LEAU 921,U

	LDD #$828f
	LDX #$c22c
	LDY #$ccff
	PSHU D,X,Y
	LDA #$ff
	LDX #$cc2c
	PSHU A,X
	RTS

