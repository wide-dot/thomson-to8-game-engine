	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_pulseball1_2
	LEAU 441,U

	LDD #$3d43
	STD 39,U
	LDD #$d3dd
	STD 119,U
	LDB #$d3
	STD -41,U
	LDB #$7d
	STD -121,U
	LEAU -320,U

	LDD #$3d33
	STD -41,U
	LDB #$44
	STD 39,U
	LDD #$d3dd
	STD 119,U
	STD -121,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$3d3d
	STD 119,U
	LDD #$d4d3
	STD 39,U
	LDD #$4d3d
	STD -41,U
	LDB #$4d
	STD -121,U
	LEAU -320,U

	STD 119,U
	LDD #$3d3d
	STD -121,U
	LDD #$d3d3
	STD -41,U
	LDA #$d4
	STD 39,U
	RTS

