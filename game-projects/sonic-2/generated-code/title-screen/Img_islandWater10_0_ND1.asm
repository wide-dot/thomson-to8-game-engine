	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_islandWater10_0
	LEAU 1040,U

	LDD #$fc2c
	LDX #$f0df
	LDY #$2fff
	PSHU D,X,Y

	LDU <glb_screen_location_1
	LEAU 1038,U

	LDD ,U
	LDA #$ff
	ANDB #$0F
	ORB #$f0
	STD ,U
	LDX #$cccf
	LDY #$2cf2
	PSHU A,X,Y
	RTS

