	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_islandWater02_0
	LEAU 737,U

	LDD ,U
	LDA #$ff
	ANDB #$0F
	ORB #$f0
	STD ,U
	LDD #$c2c2
	LDX #$c2c2
	LDY #$c2c2
	PSHU D,X,Y
	PSHU D,X,Y
	LDD #$2b2d
	PSHU D,X,Y
	LDD #$f8c0
	LDX #$2288
	LDY #$2c2d
	PSHU D,X,Y
	LDD #$c2c2
	LDX #$c2c2
	LDY #$c2c2
	PSHU D,X,Y
	LDA #$fc
	PSHU D,X

	LDU <glb_screen_location_1
	LEAU 738,U

	LDD #$cccc
	LDX #$cccc
	LDY #$cfff
	PSHU D,X,Y
	LDB #$22
	LDY #$cccc
	PSHU D,X,Y
	LDD #$2dcc
	LDX #$22cc
	PSHU D,X,Y
	LDD #$ddd2
	LDX #$2d2d
	LDY #$ddd2
	PSHU D,X,Y
	LDD #$cccc
	LDX #$cccc
	LDY #$ff88
	PSHU D,X,Y
	LDA #$ff
	LDY #$22cc
	PSHU D,X,Y
	RTS

