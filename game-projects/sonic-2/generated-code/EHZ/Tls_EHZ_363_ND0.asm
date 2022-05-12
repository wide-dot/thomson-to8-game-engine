	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_363
	LEAU 441,U

	LDD #$dddd
	STD 119,U
	LDB #$d3
	STD -121,U
	LDD #$3d44
	STD 39,U
	STD -41,U
	LEAU -320,U

	LDA #$4d
	STD 119,U
	STD 39,U
	LDD #$dd33
	STD -41,U
	LDD #$3344
	STD -121,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$dddd
	STD 119,U
	STD -121,U
	LDD #$d343
	STD 39,U
	LDB #$3d
	STD -41,U
	LEAU -320,U

	LDD #$d44d
	STD 39,U
	LDA #$d3
	STD 119,U
	LDD #$dddd
	STD -41,U
	LDD #$3333
	STD -121,U
	RTS

