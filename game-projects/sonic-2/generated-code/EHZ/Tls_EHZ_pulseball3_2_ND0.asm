	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_pulseball3_2
	LEAU 441,U

	LDD #$dddd
	STD 119,U
	LDD #$d333
	STD -41,U
	LDD #$43dd
	STD 39,U
	LDD #$7d33
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

	LDD #$d333
	STD 39,U
	LDA #$3d
	STD 119,U
	LDB #$dd
	STD -41,U
	LDA #$4d
	STD -121,U
	LEAU -320,U

	LDD #$d333
	STD -41,U
	LDB #$dd
	STD 39,U
	LDA #$4d
	STD 119,U
	LDD #$3d33
	STD -121,U
	RTS

