	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_299
	LEAU 441,U

	LDD #$1002
	STD -121,U
	LDB #$10
	STD 119,U
	STD 39,U
	STD -41,U
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

	LDD #$0111
	STD 119,U
	LDD #$2010
	STD -41,U
	STD -121,U
	LDD #$0011
	STD 39,U
	LEAU -320,U

	LDD #$1121
	STD -121,U
	LDD #$1202
	STD -41,U
	LDD #$2200
	STD 119,U
	LDB #$02
	STD 39,U
	RTS
