	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_pulseball3_0
	LEAU 441,U

	LDD #$33dd
	STD 39,U
	LDA #$dd
	STD 119,U
	LDD #$d333
	STD -41,U
	LDA #$6d
	STD -121,U
	LEAU -320,U

	LDA #$44
	STD 39,U
	LDA #$dd
	STD 119,U
	LDD #$33dd
	STD -41,U
	LDA #$dd
	STD -121,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$3d33
	STD 119,U
	LDA #$d3
	STD 39,U
	LDD #$3ddd
	STD -41,U
	STD -121,U
	LEAU -320,U

	STD 119,U
	LDA #$d3
	STD 39,U
	LDB #$33
	STD -41,U
	LDA #$3d
	STD -121,U
	RTS

