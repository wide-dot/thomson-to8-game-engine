	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_34
	LEAU 441,U

	LDD #$dd33
	STD -121,U
	LDB #$d4
	STD 39,U
	STD -41,U
	LDD #$d334
	STD 119,U
	LEAU -320,U

	LDD #$d7dd
	STD -41,U
	LDA #$dd
	STD 119,U
	STD 39,U
	LDD #$d78d
	STD -121,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$3ddd
	STD -41,U
	LDB #$3d
	STD 39,U
	LDD #$d3d3
	STD 119,U
	STD -121,U
	LEAU -320,U

	LDD #$7ddd
	STD -41,U
	LDA #$dd
	STD 119,U
	STD 39,U
	LDA #$78
	STD -121,U
	RTS

