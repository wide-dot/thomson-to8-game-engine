	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_403

	stb   <glb_alphaTiles
	LEAU 281,U

	LDD #$dd44
	STD 119,U
	LDA #$33
	STD 39,U
	STD -41,U
	LDB #$43
	STD -121,U
	LEAU -240,U

	LDD #$d3dd
	STD -41,U
	LDA #$33
	STD 39,U

	LDU <glb_screen_location_1
	LEAU 281,U

	LDD #$34dd
	STD -121,U
	LDB #$33
	STD 119,U
	STD 39,U
	STD -41,U
	LEAU -240,U

	LDD #$ddd3
	STD 39,U
	LDB #$dd
	STD -41,U
	RTS

