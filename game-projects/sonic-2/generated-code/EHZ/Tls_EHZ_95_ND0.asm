	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_95

	stb   <glb_alphaTiles
	LEAU 1,U

	LDD #$7787
	STD -1,U

	LDU <glb_screen_location_1
	LEAU 1,U

	LDD #$7878
	STD -1,U
	RTS

