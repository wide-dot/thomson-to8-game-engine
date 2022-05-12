	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_pulseball1_1
	LEAU 441,U

	LDD #$d3dd
	STD 119,U
	LDB #$d3
	STD -41,U
	LDD #$3d43
	STD 39,U
	LDD #$d36d
	STD -121,U
	LEAU -320,U

	LDB #$dd
	STD 119,U
	STD -121,U
	LDD #$3d44
	STD 39,U
	LDB #$33
	STD -41,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$3d3d
	STD 119,U
	LDD #$4d4d
	STD -121,U
	LDB #$3d
	STD -41,U
	LDD #$d4d3
	STD 39,U
	LEAU -320,U

	LDD #$3d4d
	STD 119,U
	LDB #$3d
	STD -121,U
	LDD #$d3d3
	STD 39,U
	STD -41,U
	RTS

