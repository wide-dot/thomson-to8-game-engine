	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_322
	LEAU 441,U

	LDD #$33dd
	STD 119,U
	STD 39,U
	LDD #$dd33
	STD -41,U
	STD -121,U
	LEAU -320,U

	LDB #$dd
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$dd33
	STD 119,U
	STD 39,U
	LDD #$33dd
	STD -41,U
	STD -121,U
	LEAU -320,U

	LDA #$d3
	STD 119,U
	LDA #$dd
	STD 39,U
	STD -41,U
	STD -121,U
	RTS

