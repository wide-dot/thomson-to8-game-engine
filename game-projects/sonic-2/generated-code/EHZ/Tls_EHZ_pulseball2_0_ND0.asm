	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_pulseball2_0
	LEAU 441,U

	LDD #$33d3
	STD 119,U
	LDA #$dd
	STD -41,U
	STD -121,U
	LDD #$333d
	STD 39,U
	LEAU -320,U

	LDD #$ddd3
	STD 119,U
	LDB #$3d
	STD 39,U
	LDD #$33d3
	STD -121,U
	LDB #$3d
	STD -41,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$ddd3
	STD 39,U
	LDB #$3d
	STD 119,U
	LDD #$334d
	STD -41,U
	STD -121,U
	LEAU -320,U

	LDB #$3d
	STD 119,U
	LDB #$d3
	STD 39,U
	LDA #$dd
	STD -41,U
	LDB #$3d
	STD -121,U
	RTS

