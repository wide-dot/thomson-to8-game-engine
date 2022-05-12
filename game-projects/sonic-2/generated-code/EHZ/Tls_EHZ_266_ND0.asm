	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_266

	stb   <glb_alphaTiles
	LEAU 481,U

	LDD #$33d3
	STD -1,U
	LDD #$43dd
	STD 79,U
	LDA #$dd
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LDA #$d3
	STD -81,U
	LEAU -240,U

	LDA #$dd
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$3344
	STD 79,U
	LDD #$dddd
	STD 119,U
	STD 39,U
	STD -41,U
	LDB #$d3
	STD -81,U
	LDB #$dd
	STD -121,U
	LDD #$3333
	STD -1,U
	LEAU -240,U

	LDD #$dddd
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	RTS

