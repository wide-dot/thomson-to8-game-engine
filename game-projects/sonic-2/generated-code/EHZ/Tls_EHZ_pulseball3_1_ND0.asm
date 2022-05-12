	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_pulseball3_1
	LEAU 441,U

	LDD #$dddd
	STD 119,U
	LDA #$43
	STD 39,U
	LDD #$d333
	STD -41,U
	LDA #$6d
	STD -121,U
	LEAU -320,U

	LDD #$33dd
	STD -41,U
	LDD #$4433
	STD 39,U
	LDA #$dd
	STD 119,U
	LDB #$dd
	STD -121,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$d333
	STD 39,U
	LDA #$3d
	STD 119,U
	LDB #$dd
	STD -41,U
	LDA #$4d
	STD -121,U
	LEAU -320,U

	STD 119,U
	LDA #$d3
	STD 39,U
	LDB #$33
	STD -41,U
	LDA #$3d
	STD -121,U
	RTS

