	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_296
	LEAU 441,U

	LDD #$4333
	STD 119,U
	LDD #$4444
	STD -121,U
	LDB #$33
	STD 39,U
	LDB #$34
	STD -41,U
	LEAU -320,U

	LDB #$44
	STD 119,U
	STD 39,U
	LDB #$43
	STD -41,U
	LDB #$3d
	STD -121,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$3333
	STD 119,U
	STD 39,U
	LDD #$553d
	STD -121,U
	LDA #$44
	STD -41,U
	LEAU -320,U

	LDD #$54dd
	STD -121,U
	LDA #$55
	STD -41,U
	LDB #$3d
	STD 119,U
	STD 39,U
	RTS
