	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_99
	LEAU 441,U

	LDD #$87d4
	STD 119,U
	STD 39,U
	STD -41,U
	LDB #$dd
	STD -121,U
	LEAU -320,U

	STD 119,U
	STD 39,U
	LDB #$d7
	STD -41,U
	STD -121,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$78d3
	STD 119,U
	LDD #$7ddd
	STD 39,U
	STD -41,U
	STD -121,U
	LEAU -320,U

	LDD #$7878
	STD -121,U
	LDD #$d8d8
	STD -41,U
	LDD #$dddd
	STD 119,U
	LDB #$d8
	STD 39,U
	RTS

