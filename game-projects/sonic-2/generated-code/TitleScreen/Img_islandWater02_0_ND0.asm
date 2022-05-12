	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_islandWater02_0
	LEAU 738,U

	LDD #$2c2c
	LDX #$2c2c
	LDY #$2cff
	PSHU D,X,Y
	LDB #$22
	LDY #$2c2c
	PSHU D,X,Y
	LDD #$d22c
	LDX #$222c
	PSHU D,X,Y
	LDD #$0d2d
	LDX #$82c2
	LDY #$ddbd
	PSHU D,X,Y
	LDD #$2c2c
	LDX #$2c2c
	LDY #$2f88
	PSHU D,X,Y
	LDA -6,U
	ANDA #$F0
	ORA #$0f
	STA -6,U
	LDA #$cc
	LDY #$222c
	PSHU A,X,Y

	LDU <glb_screen_location_1
	LEAU 738,U

	LDD #$cccc
	LDX #$cccc
	LDY #$ffff
	PSHU D,X,Y
	LDB #$2c
	LDY #$cccc
	PSHU D,X,Y
	LDD #$dccc
	LDX #$2ccc
	PSHU D,X,Y
	LDD #$d228
	LDX #$d2d2
	LDY #$d222
	PSHU D,X,Y
	LDD #$cccc
	LDX #$cccc
	LDY #$ff8c
	PSHU D,X,Y
	LDA #$ff
	LDY #$2ccc
	PSHU D,X,Y
	RTS

