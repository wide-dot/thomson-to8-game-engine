	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_islandWater12_0
	LEAU 1120,U

	LDD #$ffff
	LDX #$ccff
	LDY #$2fff
	PSHU D,X,Y

	LDU <glb_screen_location_1
	LEAU 1118,U

	LDD ,U
	LDA #$ff
	ANDB #$0F
	ORB #$f0
	STD ,U
	LDD #$f2fc
	LDX #$2ffc
	PSHU D,X
	RTS

