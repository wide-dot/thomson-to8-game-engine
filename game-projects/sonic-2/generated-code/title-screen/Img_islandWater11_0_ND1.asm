	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_islandWater11_0
	LEAU 1079,U

	LDA -6,U
	ANDA #$F0
	ORA #$0f
	STA -6,U
	LDA #$cc
	LDX #$f2ff
	LDY #$ffff
	PSHU A,X,Y

	LDU <glb_screen_location_1
	LEAU 1078,U

	LDA #$ff
	LDX #$fffb
	LDY #$fcff
	PSHU A,X,Y
	RTS

