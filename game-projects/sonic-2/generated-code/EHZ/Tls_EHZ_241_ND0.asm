	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_241
	LEAU 481,U

	LDD #$8744
	STD 79,U
	LDD #$dddd
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LDD #$87d4
	STD -1,U
	STD -81,U
	LEAU -280,U

	LDD #$dddd
	STD 79,U
	STD -1,U
	STD -81,U
	LDD #$87d4
	STD 119,U
	LDB #$d3
	STD 39,U
	LDB #$dd
	STD -41,U
	STD -121,U
	LEAU -180,U

	STD -21,U
	LDA #$dd
	STD 19,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$dd34
	STD -1,U
	STD -81,U
	LDA #$d3
	STD 79,U
	LDD #$dddd
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LEAU -280,U

	LDB #$34
	STD 119,U
	LDB #$dd
	STD 79,U
	STD -1,U
	STD -81,U
	LDD #$7dd4
	STD 39,U
	LDB #$d3
	STD -41,U
	LDA #$78
	STD -121,U
	LEAU -180,U

	LDD #$dddd
	STD 19,U
	LDD #$78d3
	STD -21,U
	RTS

