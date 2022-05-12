	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_pulseball2_3
	LEAU 441,U

	LDD #$33d3
	STD 119,U
	LDB #$3d
	STD 39,U
	LDD #$ddd3
	STD -41,U
	STD -121,U
	LEAU -320,U

	LDD #$333d
	STD -41,U
	LDA #$dd
	STD 39,U
	LDB #$d3
	STD 119,U
	LDA #$33
	STD -121,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$dd3d
	STD 119,U
	LDD #$3343
	STD -41,U
	LDD #$ddd4
	STD 39,U
	LDD #$335d
	STD -121,U
	LEAU -320,U

	LDB #$d4
	STD 39,U
	LDB #$43
	STD 119,U
	LDD #$ddd3
	STD -41,U
	LDB #$3d
	STD -121,U
	RTS

