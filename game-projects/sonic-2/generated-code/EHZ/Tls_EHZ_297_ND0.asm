	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_297
	LEAU 441,U

	LDD #$ddd7
	STD 119,U
	STD 39,U
	LDB #$87
	STD -41,U
	STD -121,U
	LEAU -320,U

	STD 119,U
	LDA #$d7
	STD 39,U
	LDA #$87
	STD -41,U
	STD -121,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$7878
	STD -121,U
	LDA #$d8
	STD -41,U
	LDD #$dddd
	STD 119,U
	LDB #$d8
	STD 39,U
	LEAU -320,U

	LDD #$7878
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	RTS
