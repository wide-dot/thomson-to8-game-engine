	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_252

	stb   <glb_alphaTiles

	LDU <glb_screen_location_1
	LEAU 561,U

	LDA #$d3
	STA ,U
	RTS

