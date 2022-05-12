	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_pulseball3_3
	LEAU 441,U

	LDD #$54dd
	STD 39,U
	LDA #$dd
	STD 119,U
	LDD #$3333
	STD -41,U
	LDA #$83
	STD -121,U
	LEAU -320,U

	LDA #$d3
	STD 119,U
	LDA #$54
	STD 39,U
	LDD #$dddd
	STD -121,U
	LDA #$33
	STD -41,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$3d33
	STD 119,U
	LDD #$4ddd
	STD -41,U
	STD -121,U
	LDD #$d333
	STD 39,U
	LEAU -320,U

	LDB #$dd
	STD 39,U
	LDA #$4d
	STD 119,U
	LDD #$d333
	STD -41,U
	LDA #$3d
	STD -121,U
	RTS

