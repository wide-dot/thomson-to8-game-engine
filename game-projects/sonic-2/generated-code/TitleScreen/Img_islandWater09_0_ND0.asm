	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_islandWater09_0
	LEAU 998,U

	LDD ,U
	LDA #$ff
	ANDB #$0F
	ORB #$f0
	STD ,U
	LDD #$ffff
	LDX #$0fff
	PSHU D,X

	LDU <glb_screen_location_1
	LEAU 999,U

	LDA #$f2
	LDX #$fffc
	LDY #$2fff
	PSHU A,X,Y
	RTS

