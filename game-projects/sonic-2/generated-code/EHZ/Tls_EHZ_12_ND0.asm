	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_12
	LEAU 441,U

	LDD #$3334
	STD 39,U
	LDD #$d354
	STD 119,U
	LDD #$33d4
	STD -41,U
	LDD #$d3dd
	STD -121,U
	LEAU -320,U

	LDD #$dd87
	STD -121,U
	LDB #$dd
	STD 39,U
	LDB #$d7
	STD -41,U
	LDD #$3ddd
	STD 119,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$d4d3
	STD 119,U
	LDD #$dd3d
	STD -41,U
	STD -121,U
	LDA #$4d
	STD 39,U
	LEAU -320,U

	LDD #$dddd
	STD 119,U
	STD 39,U
	LDD #$78d8
	STD -121,U
	LDD #$d8dd
	STD -41,U
	RTS

