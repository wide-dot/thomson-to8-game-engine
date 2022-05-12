	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_407
	LEAU 441,U

	LDD #$8d8d
	STD 119,U
	LDD #$dd3d
	STD -121,U
	LDB #$dd
	STD 39,U
	STD -41,U
	LEAU -320,U

	LDB #$33
	STD 119,U
	STD 39,U
	LDD #$33dd
	STD -41,U
	STD -121,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$7d78
	STD 119,U
	LDD #$ddd8
	STD 39,U
	LDB #$dd
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

