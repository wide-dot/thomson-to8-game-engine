	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_315
	LEAU 441,U

	LDD #$dd4d
	STD 119,U
	LDB #$3d
	STD 39,U
	LDB #$dd
	STD -41,U
	STD -121,U
	LEAU -320,U

	LDD #$d7d7
	STD 119,U
	STD 39,U
	STD -41,U
	LDB #$87
	STD -121,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$dddd
	STD -41,U
	STD -121,U
	LDA #$3d
	STD 39,U
	LDD #$4333
	STD 119,U
	LEAU -320,U

	LDD #$7ddd
	STD 119,U
	LDB #$d8
	STD 39,U
	LDD #$7878
	STD -121,U
	LDB #$d8
	STD -41,U
	RTS

