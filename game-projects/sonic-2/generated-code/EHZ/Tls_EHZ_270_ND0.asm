	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_270
	LEAU 441,U

	LDD #$d444
	STD -41,U
	LDD #$dd4d
	STD 39,U
	LDD #$3333
	STD 119,U
	LDD #$dd3d
	STD -121,U
	LEAU -320,U

	STD -41,U
	LDD #$d343
	STD 39,U
	LDD #$dddd
	STD 119,U
	STD -121,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$3333
	STD 119,U
	LDD #$44d4
	STD -41,U
	LDB #$dd
	STD -121,U
	LDA #$34
	STD 39,U
	LEAU -320,U

	LDD #$44d3
	STD 39,U
	LDD #$34dd
	STD 119,U
	STD -41,U
	LDA #$dd
	STD -121,U
	RTS

