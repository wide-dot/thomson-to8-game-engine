	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_143

	stb   <glb_alphaTiles
	LEAU 441,U

	LDD #$8787
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LEAU -280,U

	STD 79,U
	STD -1,U
	STD -81,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$7878
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LEAU -280,U

	STD 79,U
	STD -1,U
	LDD -81,U
	ANDA #$F0
	ANDB #$F0
	ADDD #$0808
	STD -81,U
	RTS

