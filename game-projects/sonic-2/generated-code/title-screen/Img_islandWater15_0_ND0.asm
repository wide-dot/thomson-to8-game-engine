	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_islandWater15_0
	LEAU 1237,U

	LDD #$fcff
	STD -1,U

	LDU <glb_screen_location_1
	LEAU 1238,U

	LDA #$ff
	LDX #$ffff
	PSHU A,X
	RTS

