	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_pulseball1_0
	LEAU 441,U

	LDD #$3d33
	STD 39,U
	LDD #$d3dd
	STD 119,U
	LDB #$d3
	STD -41,U
	LDB #$6d
	STD -121,U
	LEAU -320,U

	LDD #$3d44
	STD 39,U
	LDD #$d3dd
	STD 119,U
	STD -121,U
	LDD #$3d33
	STD -41,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$4d3d
	STD -41,U
	STD -121,U
	LDD #$d3d3
	STD 39,U
	LDD #$3d3d
	STD 119,U
	LEAU -320,U

	LDD #$d3d3
	STD 39,U
	STD -41,U
	LDD #$3d3d
	STD 119,U
	STD -121,U
	RTS

