	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_islandWater06_0
	LEAU 897,U

	LDD #$f2ff
	LDX #$f2ff
	LDY #$f2ff
	PSHU D,X,Y
	LEAU -2,U

	LDD -7,U
	LDA #$ff
	ANDB #$0F
	ORB #$f0
	STD -7,U
	PSHU X,Y
	LEAU -3,U

	LDD #$dd8c
	LDX #$22dd
	LDY #$2fff
	PSHU D,X,Y
	LDD #$f2ff
	STD -10,U
	LDX #$f2cc
	LDY #$2ddf
	PSHU D,X,Y

	LDU <glb_screen_location_1
	LEAU 897,U

	LDA #$ff
	STA -7,U
	LDD #$ffff
	LDX #$ffff
	LDY #$ffff
	PSHU D,X,Y
	LEAU -2,U

	PSHU A,X,Y
	LEAU -1,U

	LDD #$28fc
	LDX #$f2ff
	LDY #$cfff
	PSHU D,X,Y
	LDD #$ffff
	STD -8,U
	LDB #$fc
	LDX #$cbdc
	LDY #$fffd
	PSHU D,X,Y
	LEAU -3,U

	LDX #$ffff
	PSHU A,X
	RTS

