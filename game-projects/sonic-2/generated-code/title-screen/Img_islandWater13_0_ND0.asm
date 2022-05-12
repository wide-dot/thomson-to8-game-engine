	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_islandWater13_0
	LEAU 1159,U

	LDA #$ff
	LDX #$2fff
	LDY #$2fff
	PSHU A,X,Y

	LDU <glb_screen_location_1
	LEAU 1157,U

	LDD ,U
	LDA #$ff
	ANDB #$0F
	ORB #$f0
	STD ,U
	LDA #$f2
	LDX #$ffff
	PSHU A,X
	RTS

