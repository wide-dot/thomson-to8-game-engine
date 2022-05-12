	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_118
	LEAU 441,U

	LDD #$d343
	STD 119,U
	LDD #$dddd
	STD -41,U
	STD -121,U
	LDD #$d33d
	STD 39,U
	LEAU -320,U

	LDD #$d7dd
	STD 119,U
	STD 39,U
	LDD #$87d7
	STD -41,U
	STD -121,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$3334
	STD 119,U
	LDD #$d333
	STD 39,U
	LDD #$dddd
	STD -121,U
	LDB #$33
	STD -41,U
	LEAU -320,U

	LDD #$d8dd
	STD 39,U
	LDA #$dd
	STD 119,U
	LDD #$787d
	STD -41,U
	LDB #$78
	STD -121,U
	RTS

