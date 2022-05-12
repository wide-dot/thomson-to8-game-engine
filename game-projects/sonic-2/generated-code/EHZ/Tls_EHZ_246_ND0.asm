	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_246
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	STD 39,U
	STD -41,U
	LDB #$d3
	STD -81,U
	LDB #$dd
	STD -121,U
	LDB #$34
	STD -1,U
	LDB #$44
	STD 79,U
	LEAU -280,U

	LDB #$dd
	STD 119,U
	STD 79,U
	STD -1,U
	STD -81,U
	LDA #$d7
	STD 39,U
	STD -41,U
	STD -121,U
	LEAU -180,U

	LDB #$d7
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
	LDD #$4333
	STD 79,U
	LDA #$3d
	STD -1,U
	LDA #$dd
	STD -81,U
	LEAU -280,U

	LDB #$d3
	STD 119,U
	LDB #$dd
	STD 79,U
	STD -1,U
	STD -81,U
	LDA #$7d
	STD 39,U
	LDB #$7d
	STD -41,U
	LDA #$78
	STD -121,U
	LEAU -180,U

	LDD #$dddd
	STD 19,U
	LDD #$7878
	STD -21,U
	RTS

