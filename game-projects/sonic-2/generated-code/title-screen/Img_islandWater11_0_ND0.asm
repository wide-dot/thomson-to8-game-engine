	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_islandWater11_0
	LEAU 1077,U

	LDD ,U
	LDA #$ff
	ANDB #$0F
	ORB #$f0
	STD ,U
	LDD #$ffcf
	LDX #$2fff
	PSHU D,X

	LDU <glb_screen_location_1
	LEAU 1078,U

	LDA #$fc
	LDX #$ffbf
	LDY #$cfff
	PSHU A,X,Y
	RTS

