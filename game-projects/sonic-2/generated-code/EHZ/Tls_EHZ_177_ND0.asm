	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_177

	stb   <glb_alphaTiles
	LEAU 441,U

	LDD #$ddd7
	STD 119,U
	LDD #$8787
	STD -121,U
	LDB #$d7
	STD 39,U
	STD -41,U
	LEAU -320,U

	LDB #$87
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$dd78
	STD 119,U
	LDA #$7d
	STD 39,U
	STD -41,U
	LDA #$78
	STD -121,U
	LEAU -320,U

	STD 119,U
	STD 39,U
	LDB #$87
	STD -41,U
	LDD -121,U
	LDA #$78
	ANDB #$0F
	ORB #$80
	STD -121,U
	RTS

