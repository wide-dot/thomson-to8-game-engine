	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_0

	stb   <glb_alphaTiles

	LDU <glb_screen_location_1
	RTS

