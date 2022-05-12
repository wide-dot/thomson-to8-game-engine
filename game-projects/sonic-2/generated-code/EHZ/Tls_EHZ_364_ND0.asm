	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_364
	LEAU 441,U

	LDD #$dd44
	STD 119,U
	LDB #$4d
	STD -41,U
	LDB #$dd
	STD -121,U
	LDD #$3344
	STD 39,U
	LEAU -320,U

	LDD #$d44d
	STD 119,U
	STD 39,U
	LDD #$3333
	STD -121,U
	LDD #$dddd
	STD -41,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$d4dd
	STD 119,U
	LDA #$44
	STD 39,U
	LDA #$34
	STD -41,U
	LDD #$d3d3
	STD -121,U
	LEAU -320,U

	LDD #$44d4
	STD 119,U
	LDB #$d3
	STD 39,U
	LDD #$34dd
	STD -41,U
	LDD #$4433
	STD -121,U
	RTS

