	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_islandWater12_0
	LEAU 1120,U

	LDD #$ffff
	LDX #$c2ff
	LDY #$ffff
	PSHU D,X,Y

	LDU <glb_screen_location_1
	LEAU 1119,U

	LDA -6,U
	ANDA #$F0
	ORA #$0f
	STA -6,U
	LDA #$2f
	LDX #$ccff
	LDY #$c2ff
	PSHU A,X,Y
	RTS

