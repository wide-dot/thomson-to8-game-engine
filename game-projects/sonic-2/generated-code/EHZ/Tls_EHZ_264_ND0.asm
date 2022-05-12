	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_264

	stb   <glb_alphaTiles
	LEAU 441,U

	LDD #$3344
	STD -41,U
	STD -121,U
	LDD #$3dd3
	STD 39,U
	LDD #$dddd
	STD 119,U
	LEAU -240,U

	LDD #$3344
	STD 39,U
	LDB #$3d
	STD -41,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$dddd
	STD 119,U
	LDD #$3433
	STD -41,U
	STD -121,U
	LDA #$dd
	STD 39,U
	LEAU -240,U

	LDD #$33dd
	STD -41,U
	LDD #$3433
	STD 39,U
	RTS

