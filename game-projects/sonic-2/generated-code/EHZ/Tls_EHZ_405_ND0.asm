	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_405
	LEAU 441,U

	LDD #$dd3d
	STD -41,U
	LDB #$33
	STD -121,U
	LDB #$dd
	STD 119,U
	STD 39,U
	LEAU -320,U

	LDA #$33
	STD -41,U
	STD -121,U
	LDD #$dd33
	STD 119,U
	STD 39,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$dddd
	STD 119,U
	STD 39,U
	LDA #$3d
	STD -41,U
	LDA #$33
	STD -121,U
	LEAU -320,U

	STD 119,U
	STD 39,U
	LDD #$dd33
	STD -41,U
	STD -121,U
	RTS

