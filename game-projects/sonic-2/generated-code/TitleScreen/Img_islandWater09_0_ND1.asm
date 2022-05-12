	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_islandWater09_0
	LEAU 1000,U

	LDA -6,U
	ANDA #$F0
	ORA #$0f
	STA -6,U
	LDA #$2f
	LDX #$f0cf
	LDY #$ffff
	PSHU A,X,Y

	LDU <glb_screen_location_1
	LEAU 999,U

	LDA #$ff
	LDX #$ffff
	LDY #$f2ff
	PSHU A,X,Y
	RTS

