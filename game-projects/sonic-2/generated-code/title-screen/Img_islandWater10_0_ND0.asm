	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_islandWater10_0
	LEAU 1040,U

	LDA -7,U
	ANDA #$F0
	ORA #$0f
	STA -7,U
	LDD #$cccc
	LDX #$02ff
	LDY #$ffff
	PSHU D,X,Y

	LDU <glb_screen_location_1
	LEAU 1039,U

	LDD #$ffc2
	LDX #$ffcd
	LDY #$22ff
	PSHU D,X,Y
	RTS

