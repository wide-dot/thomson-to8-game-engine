	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_385

	stb   <glb_alphaTiles
	LEAU 481,U

	LDD #$343d
	STD -1,U
	LDD #$dddd
	STD 119,U
	STD 79,U
	STD 39,U
	STD -41,U
	STD -121,U
	LDD #$444d
	STD -81,U
	LEAU -280,U

	LDD #$d4dd
	STD -41,U
	LDA #$dd
	STD 79,U
	STD 39,U
	STD -1,U
	STD -81,U
	LDA #$d3
	STD 119,U
	LDD #$444d
	STD -121,U
	LEAU -180,U

	LDD #$3433
	STD -21,U
	LDD #$dddd
	STD 19,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LDD #$4434
	STD -1,U
	STD -81,U
	LDD #$3ddd
	STD 79,U
	LEAU -280,U

	STD 39,U
	LDA #$dd
	STD 79,U
	STD -1,U
	STD -81,U
	LDA #$43
	STD 119,U
	LDD #$443d
	STD -41,U
	LDB #$dd
	STD -121,U
	LEAU -180,U

	LDD -21,U
	LDA #$44
	ANDB #$0F
	ORB #$d0
	STD -21,U
	LDD #$dddd
	STD 19,U
	RTS

