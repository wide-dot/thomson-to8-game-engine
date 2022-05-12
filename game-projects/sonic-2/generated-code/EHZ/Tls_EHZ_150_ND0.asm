	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_150
	LEAU 441,U

	LDD #$ddd7
	STD -41,U
	STD -121,U
	LDD #$d3dd
	STD 119,U
	STD 39,U
	LEAU -320,U

	LDD #$dd87
	STD 39,U
	LDB #$d7
	STD 119,U
	LDD #$d787
	STD -41,U
	LDA #$87
	STD -121,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$44dd
	STD 119,U
	LDD #$dd7d
	STD -121,U
	LDA #$d3
	STD -41,U
	LDD #$34dd
	STD 39,U
	LEAU -320,U

	LDD #$dd7d
	STD 119,U
	LDB #$78
	STD 39,U
	STD -41,U
	LDA #$d8
	STD -121,U
	RTS

