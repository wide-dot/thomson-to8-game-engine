	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_105
	LEAU 481,U

	LDD #$d334
	STD 79,U
	LDD #$dddd
	STD 119,U
	STD 39,U
	LDB #$d4
	STD -1,U
	LDB #$dd
	STD -41,U
	LDB #$d4
	STD -81,U
	LDB #$dd
	STD -121,U
	LEAU -280,U

	LDB #$33
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

	LDB #$8d
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
	LDD #$d3d3
	STD 79,U
	LDD #$3d3d
	STD -1,U
	LDB #$dd
	STD -81,U
	LEAU -280,U

	LDA #$7d
	STD -121,U
	LDA #$dd
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	LDD #$d3d3
	STD 119,U
	LEAU -180,U

	LDD #$78dd
	STD -21,U
	LDA #$dd
	STD 19,U
	RTS

