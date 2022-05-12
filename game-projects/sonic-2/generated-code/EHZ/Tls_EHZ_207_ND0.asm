	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_207

	stb   <glb_alphaTiles
	LEAU 561,U

	LDD -1,U
	LDA #$87
	ANDB #$F0
	ORB #$07
	STD -1,U

	LDU <glb_screen_location_1
	LEAU 561,U

	LDD -1,U
	ANDA #$0F
	ORA #$70
	LDB #$78
	STD -1,U
	RTS

