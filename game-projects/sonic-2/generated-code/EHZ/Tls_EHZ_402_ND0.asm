	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_402

	stb   <glb_alphaTiles
	LEAU 321,U

	LDD #$dddd
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	LDB #$d3
	STD -81,U
	LDB #$dd
	STD -121,U
	LEAU -240,U

	LDD #$33d4
	STD -1,U
	LDA #$dd
	STD 79,U
	LDB #$dd
	STD 39,U
	STD -41,U
	LDD #$44d4
	STD -81,U

	LDU <glb_screen_location_1
	LEAU 321,U

	LDD #$dd44
	STD -81,U
	LDB #$dd
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -121,U
	LEAU -240,U

	LDD -81,U
	LDA #$dd
	ANDB #$0F
	ORB #$40
	STD -81,U
	LDD #$dddd
	STD 39,U
	STD -41,U
	LDB #$44
	STD 79,U
	STD -1,U
	RTS

