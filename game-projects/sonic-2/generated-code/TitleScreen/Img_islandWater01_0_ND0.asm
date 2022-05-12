	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_islandWater01_0
	LEAU 698,U

	LDD #$0000
	LDX #$0000
	LDY #$00ff
	PSHU D,X,Y
	LDB #$d0
	LDX #$d000
	LDY #$0000
	PSHU D,X,Y
	LDD #$bd00
	LDX #$d0d0
	PSHU D,X,Y
	LDD #$88d8
	LDX #$2822
	LDY #$28d2
	PSHU D,X,Y
	LDD #$0000
	LDX #$0000
	LDY #$222d
	PSHU D,X,Y
	LDA -6,U
	ANDA #$F0
	ORA #$0f
	STA -6,U
	LDY #$d0d0
	PSHU B,X,Y

	LDU <glb_screen_location_1
	LEAU 698,U

	LDD #$2020
	LDX #$2020
	LDY #$ffff
	PSHU D,X,Y
	LDD #$2222
	LDY #$2020
	PSHU D,X,Y
	LDA #$20
	LDX #$2220
	PSHU D,X,Y
	LDD #$802d
	LDX #$8d88
	LDY #$2bdd
	PSHU D,X,Y
	LDD #$2020
	LDX #$20dc
	LDY #$dd80
	PSHU D,X,Y
	LDA #$ff
	LDX #$2022
	LDY #$2220
	PSHU D,X,Y
	RTS

