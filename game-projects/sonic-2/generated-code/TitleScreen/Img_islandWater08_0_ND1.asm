	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_islandWater08_0
	LEAU 960,U

	LDA #$ff
	STA -7,U
	LDD #$ff2f
	LDX #$fccf
	LDY #$2fff
	PSHU D,X,Y

	LDU <glb_screen_location_1
	LEAU 958,U

	LDD ,U
	LDA #$ff
	ANDB #$0F
	ORB #$f0
	STD ,U
	LDA -6,U
	ANDA #$F0
	ORA #$0f
	STA -6,U
	LDA #$cf
	LDX #$ccff
	LDY #$22ff
	PSHU A,X,Y
	RTS

