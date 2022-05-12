	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_islandWater05_0
	LEAU 856,U

	LDD #$fbff
	STD -10,U
	LDX #$fbff
	LDY #$fbff
	PSHU D,X,Y
	LEAU -6,U

	LDD #$bc8c
	LDX #$ccff
	PSHU D,X,Y
	LDD #$ffdf
	LDX #$c2c2
	LDY #$22dc
	PSHU D,X,Y
	LDD #$fbff
	STD -7,U
	LDX #$fffb
	PSHU A,X

	LDU <glb_screen_location_1
	LEAU 856,U

	LDA #$ff
	STA -7,U
	LDD #$ffff
	LDX #$ffff
	LDY #$ffff
	PSHU D,X,Y
	LEAU -2,U

	PSHU A,X
	LEAU -1,U

	LDD #$c222
	LDX #$2cff
	PSHU D,X,Y
	LDD #$ff82
	LDX #$ff22
	LDY #$ddbc
	PSHU D,X,Y
	LDB #$ff
	LDX #$ffff
	PSHU D,X
	LEAU -1,U

	PSHU A,X
	RTS

