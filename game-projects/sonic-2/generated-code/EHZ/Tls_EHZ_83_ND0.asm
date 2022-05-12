	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_83

	stb   <glb_alphaTiles
	LEAU 1,U

	LDD #$8787
	STD -1,U

	LDU <glb_screen_location_1
	LEAU 1,U

	LDD #$7877
	STD -1,U
	RTS

