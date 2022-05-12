	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_125
	LEAU 441,U

	LDD #$d334
	STD 119,U
	LDB #$d3
	STD 39,U
	LDD #$dddd
	STD -41,U
	STD -121,U
	LEAU -320,U

	STD 119,U
	STD 39,U
	LDD #$d78d
	STD -41,U
	LDD #$8787
	STD -121,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$d3dd
	STD -41,U
	LDA #$34
	STD 39,U
	LDD #$44d3
	STD 119,U
	LDD #$dddd
	STD -121,U
	LEAU -320,U

	LDB #$78
	STD 39,U
	STD -41,U
	LDB #$dd
	STD 119,U
	LDD #$d878
	STD -121,U
	RTS

