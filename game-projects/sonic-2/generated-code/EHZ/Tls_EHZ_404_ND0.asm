	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_404
	LEAU 441,U

	LDD #$d7d7
	STD 119,U
	LDD #$dddd
	STD 39,U
	STD -41,U
	LDB #$3d
	STD -121,U
	LEAU -320,U

	LDD #$33dd
	STD -41,U
	STD -121,U
	LDD #$dd33
	STD 119,U
	STD 39,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$78d8
	STD 119,U
	LDD #$7ddd
	STD 39,U
	LDA #$dd
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

