	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_421
	LEAU 441,U

	LDD #$1010
	STD -41,U
	LDD #$a01a
	STD 119,U
	LDB #$10
	STD 39,U
	LDD #$1002
	STD -121,U
	LEAU -320,U

	LDD #$0022
	STD 39,U
	LDB #$02
	STD 119,U
	LDD #$0221
	STD -41,U
	STD -121,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$2010
	STD -41,U
	STD -121,U
	LDD #$a011
	STD 39,U
	LDD #$a11e
	STD 119,U
	LEAU -320,U

	LDD #$2200
	STD 119,U
	LDB #$02
	STD 39,U
	LDA #$21
	STD -41,U
	LDB #$21
	STD -121,U
	RTS
