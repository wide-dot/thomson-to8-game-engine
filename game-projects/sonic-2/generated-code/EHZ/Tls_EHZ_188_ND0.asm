	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_188

	stb   <glb_alphaTiles
	LEAU 561,U

	LDD #$8787
	STD -1,U

	LDU <glb_screen_location_1
	LEAU 561,U

	LDD -1,U
	ANDA #$F0
	ANDB #$F0
	ADDD #$0808
	STD -1,U
	RTS

