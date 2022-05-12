	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_193
	LEAU 441,U

	LDD #$3d3d
	STD 39,U
	LDD #$4333
	STD 119,U
	LDD #$d33d
	STD -41,U
	LDB #$33
	STD -121,U
	LEAU -320,U

	LDD #$d7dd
	STD -121,U
	LDA #$dd
	STD 119,U
	STD 39,U
	STD -41,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$3333
	STD 119,U
	STD -121,U
	LDD #$3d34
	STD 39,U
	LDB #$33
	STD -41,U
	LEAU -320,U

	LDA #$dd
	STD 119,U
	LDD #$7ddd
	STD -41,U
	LDA #$dd
	STD 39,U
	LDA #$78
	STD -121,U
	RTS

