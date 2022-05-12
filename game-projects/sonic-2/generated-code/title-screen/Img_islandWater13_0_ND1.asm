	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_islandWater13_0
	LEAU 1159,U

	LDA -5,U
	ANDA #$F0
	ORA #$0f
	STA -5,U
	LDD #$22ff
	LDX #$f2ff
	PSHU D,X

	LDU <glb_screen_location_1
	LEAU 1159,U

	LDA #$ff
	LDX #$ffff
	LDY #$ffff
	PSHU A,X,Y
	RTS

