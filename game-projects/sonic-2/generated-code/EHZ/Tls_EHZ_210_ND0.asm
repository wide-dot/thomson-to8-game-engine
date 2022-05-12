	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_210

	stb   <glb_alphaTiles
	LEAU 441,U

	LDD #$8787
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LEAU -320,U

	STD 119,U
	LDA #$88
	STD 39,U
	LDA #$78
	STD -41,U
	STB -120,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$7878
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LEAU -320,U

	STD 119,U
	STD 39,U
	LDA #$88
	STD -41,U
	STD -121,U
	RTS

