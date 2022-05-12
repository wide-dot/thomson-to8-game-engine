	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_islandWater15_0
	LEAU 1237,U

	LDD ,U
	LDA #$ff
	ANDB #$0F
	ORB #$f0
	STD ,U
	STA -1,U

	LDU <glb_screen_location_1
	LEAU 1236,U

	LDA -1,U
	ANDA #$F0
	ORA #$0f
	STA -1,U
	LDD #$cfff
	STD ,U
	RTS

