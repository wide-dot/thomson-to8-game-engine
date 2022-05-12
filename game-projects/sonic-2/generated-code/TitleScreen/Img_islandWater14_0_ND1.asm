	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_islandWater14_0
	LEAU 1199,U

	LDA -4,U
	ANDA #$F0
	ORA #$0f
	STA -4,U
	LDA #$cf
	LDX #$cfff
	PSHU A,X

	LDU <glb_screen_location_1
	LEAU 1197,U

	LDD #$fffc
	STD -2,U
	LDD ,U
	LDA #$ff
	ANDB #$0F
	ORB #$f0
	STD ,U
	RTS

