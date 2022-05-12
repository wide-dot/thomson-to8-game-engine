	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_411
	LEAU 441,U

	LDD #$dd3d
	STD -121,U
	LDB #$dd
	STD 39,U
	STD -41,U
	LDD #$d7d7
	STD 119,U
	LEAU -320,U

	LDD #$33dd
	STD -41,U
	STD -121,U
	LDD #$dd33
	STD 119,U
	STD 39,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$dddd
	STD -41,U
	LDA #$7d
	STD 39,U
	LDA #$78
	STD 119,U
	LDA #$33
	STD -121,U
	LEAU -320,U

	LDD #$dd33
	STD -41,U
	STD -121,U
	LDD #$33dd
	STD 119,U
	STD 39,U
	RTS

