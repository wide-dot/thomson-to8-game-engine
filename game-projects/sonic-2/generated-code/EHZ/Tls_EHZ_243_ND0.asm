	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_243
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LDD #$d7d7
	STD 79,U
	LDA #$87
	STD -1,U
	STD -81,U
	LEAU -280,U

	STD 119,U
	LDD #$dddd
	STD 79,U
	STD -1,U
	STD -81,U
	LDD #$8787
	STD 39,U
	STD -41,U
	STD -121,U
	LEAU -180,U

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
	LDA #$78
	STD 79,U
	STD -1,U
	LDB #$7d
	STD -81,U
	LEAU -280,U

	LDD #$dddd
	STD 79,U
	STD -1,U
	STD -81,U
	LDD #$787d
	STD 119,U
	LDB #$78
	STD 39,U
	STD -41,U
	STD -121,U
	LEAU -180,U

	LDD #$dddd
	STD 19,U
	LDD #$7878
	STD -21,U
	RTS
