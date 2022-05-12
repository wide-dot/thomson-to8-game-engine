	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_323
	LEAU 441,U

	LDD #$dddd
	STD 119,U
	STD 39,U
	LDB #$33
	STD -41,U
	STD -121,U
	LEAU -320,U

	LDB #$dd
	STD -41,U
	STD -121,U
	LDB #$33
	STD 119,U
	STD 39,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$dddd
	STD -41,U
	STD -121,U
	LDB #$33
	STD 119,U
	STD 39,U
	LEAU -320,U

	LDB #$dd
	STD 119,U
	STD 39,U
	LDB #$33
	STD -41,U
	STD -121,U
	RTS

