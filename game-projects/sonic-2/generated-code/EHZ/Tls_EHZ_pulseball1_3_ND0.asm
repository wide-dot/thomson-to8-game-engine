	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_pulseball1_3
	LEAU 441,U

	LDD #$d3dd
	STD 119,U
	LDD #$3d54
	STD 39,U
	LDD #$d333
	STD -41,U
	LDB #$83
	STD -121,U
	LEAU -320,U

	LDD #$3d54
	STD 39,U
	LDD #$d3d3
	STD 119,U
	LDB #$dd
	STD -121,U
	LDD #$3d33
	STD -41,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$3d3d
	STD 119,U
	LDD #$434d
	STD -41,U
	LDD #$d4d3
	STD 39,U
	LDD #$5d4d
	STD -121,U
	LEAU -320,U

	LDD #$d3d3
	STD -41,U
	LDA #$d4
	STD 39,U
	LDD #$434d
	STD 119,U
	LDD #$3d3d
	STD -121,U
	RTS

