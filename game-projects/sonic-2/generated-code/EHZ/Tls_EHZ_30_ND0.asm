	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_30
	LEAU 441,U

	LDD #$d3dd
	STD -41,U
	LDD #$3d3d
	STD 39,U
	LDD #$4333
	STD 119,U
	LDA #$d3
	STD -121,U
	LEAU -320,U

	LDD #$dddd
	STD 119,U
	STD 39,U
	LDB #$d7
	STD -41,U
	LDA #$d7
	STD -121,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$33dd
	STD -121,U
	LDD #$3d34
	STD 39,U
	STD -41,U
	LDD #$3333
	STD 119,U
	LEAU -320,U

	LDD #$dddd
	STD 119,U
	STD 39,U
	LDA #$7d
	STD -41,U
	LDD #$78d8
	STD -121,U
	RTS

