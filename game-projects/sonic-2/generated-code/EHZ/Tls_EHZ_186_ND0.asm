	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_186

	stb   <glb_alphaTiles
	LEAU 561,U

	LDD #$8787
	STD -1,U

	LDU <glb_screen_location_1
	LEAU 561,U

	LDD -1,U
	ANDA #$0F
	ANDB #$F0
	ADDD #$7008
	STD -1,U
	RTS

