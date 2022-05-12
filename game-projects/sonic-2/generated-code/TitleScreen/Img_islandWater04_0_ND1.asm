	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_islandWater04_0
	LEAU 813,U

	LDD ,U
	LDA #$cf
	ANDB #$F0
	ORB #$0f
	STD ,U
	LDD #$ccff
	STD 2,U
	LDB #$2c
	LDX #$ccff
	LDY #$ccff
	PSHU D,X,Y
	LDD #$2cff
	LDX #$2ccc
	PSHU D,X,Y
	LDD #$b2bd
	LDX #$df2b
	LDY #$2282
	PSHU D,X,Y
	LDD #$ffcc
	LDX #$ffcc
	LDY #$c2c2
	PSHU D,X,Y
	LDA -4,U
	ANDA #$F0
	ORA #$0f
	STA -4,U
	LDX #$2ccc
	PSHU B,X

	LDU <glb_screen_location_1
	LEAU 817,U

	LDD #$ffff
	LDX #$ffff
	LDY #$ffff
	PSHU D,X,Y
	LDX #$fc2c
	PSHU D,X,Y
	LDD #$d222
	LDX #$cffc
	LDY #$2cff
	PSHU D,X,Y
	LDD #$fc80
	LDX #$dd02
	LDY #$2df8
	PSHU D,X,Y
	LDD #$fffc
	STD -8,U
	LDD #$2cff
	LDX #$ffff
	LDY #$fffc
	PSHU D,X,Y
	RTS

