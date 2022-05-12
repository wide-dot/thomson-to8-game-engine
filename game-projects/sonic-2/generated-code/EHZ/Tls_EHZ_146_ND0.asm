	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_146

	stb   <glb_alphaTiles
	LEAU 520,U

	LDD #$8787
	STD 40,U
	STA -40,U

	LDU <glb_screen_location_1
	LEAU 520,U

	LDA -40,U
	ANDA #$F0
	ORA #$08
	STA -40,U
	LDD 40,U
	LDA #$78
	ANDB #$F0
	ORB #$08
	STD 40,U
	RTS

