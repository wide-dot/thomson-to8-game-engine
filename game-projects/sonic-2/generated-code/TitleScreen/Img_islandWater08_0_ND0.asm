	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_islandWater08_0
	LEAU 960,U

	LDA #$fc
	STA -7,U
	LDD #$fcff
	LDX #$c2ff
	LDY #$ffff
	PSHU D,X,Y

	LDU <glb_screen_location_1
	LEAU 959,U

	LDA #$ff
	STA -7,U
	LDD #$ffc2
	LDX #$ff2c
	LDY #$f2ff
	PSHU D,X,Y
	RTS

