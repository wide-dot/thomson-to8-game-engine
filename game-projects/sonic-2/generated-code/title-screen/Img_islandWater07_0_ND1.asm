	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_islandWater07_0
	LEAU 922,U

	LDD #$2df0
	LDX #$2ccc
	LDY #$cfff
	PSHU D,X,Y
	LDA #$f2
	LDX #$c2c2
	PSHU A,X

	LDU <glb_screen_location_1
	LEAU 920,U

	LDD #$ff2c
	STD -8,U
	LDD ,U
	LDA #$ff
	ANDB #$0F
	ORB #$f0
	STD ,U
	LDD #$c2d8
	LDX #$c8cc
	LDY #$c2cc
	PSHU D,X,Y
	RTS

