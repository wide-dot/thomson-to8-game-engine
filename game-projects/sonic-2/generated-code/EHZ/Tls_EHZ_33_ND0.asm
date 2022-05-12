	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_33
	LEAU 441,U

	LDD #$4333
	STD 119,U
	LDD #$dd3d
	STD 39,U
	STD -41,U
	LDD #$d333
	STD -121,U
	LEAU -320,U

	LDD #$dddd
	STD 119,U
	STD 39,U
	LDA #$d7
	STD -41,U
	STD -121,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$3333
	STD 119,U
	LDB #$34
	STD 39,U
	LDB #$33
	STD -121,U
	LDA #$d3
	STD -41,U
	LEAU -320,U

	LDD #$78dd
	STD -121,U
	LDA #$dd
	STD 39,U
	LDA #$7d
	STD -41,U
	LDD #$dd33
	STD 119,U
	RTS

