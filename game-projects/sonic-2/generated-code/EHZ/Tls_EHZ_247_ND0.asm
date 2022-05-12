	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_247
	LEAU 481,U

	LDD #$dd34
	STD -1,U
	STD -81,U
	LDD #$d354
	STD 79,U
	LDD #$dddd
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LEAU -280,U

	LDB #$d3
	STD 119,U
	LDB #$dd
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	LDA #$d7
	STD -121,U
	LEAU -180,U

	LDA #$dd
	STD 19,U
	LDA #$d7
	STD -21,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$3d4d
	STD -1,U
	STD -81,U
	LDD #$d3d4
	STD 79,U
	LDD #$dddd
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LEAU -280,U

	LDA #$d3
	STD 119,U
	LDA #$dd
	STD 79,U
	LDB #$d3
	STD 39,U
	LDB #$dd
	STD -1,U
	STD -81,U
	LDD #$7d3d
	STD -121,U
	LDA #$dd
	STD -41,U
	LEAU -180,U

	LDB #$dd
	STD 19,U
	LDA #$78
	STD -21,U
	RTS

