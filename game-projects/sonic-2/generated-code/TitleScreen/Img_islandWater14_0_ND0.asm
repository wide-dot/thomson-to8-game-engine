	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_islandWater14_0
	LEAU 1199,U

	LDD #$ffff
	LDX #$ffff
	PSHU D,X

	LDU <glb_screen_location_1
	LEAU 1198,U

	LDA #$fc
	LDX #$ccff
	PSHU A,X
	RTS

