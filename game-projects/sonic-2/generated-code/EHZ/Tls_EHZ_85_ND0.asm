	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_85

	stb   <glb_alphaTiles
	LEAU 441,U

	LDD #$d787
	STD -41,U
	STD -121,U
	LDA #$87
	STD 119,U
	LDB #$88
	STD 39,U
	LEAU -320,U

	LDD #$3d87
	STD -41,U
	STD -121,U
	LDA #$d7
	STD 119,U
	STD 39,U

	LDU <glb_screen_location_1
	LEAU 440,U

	LDA #$78
	STA 120,U
	STA 40,U
	LDD #$7887
	STD -40,U
	LDB #$78
	STD -120,U
	LEAU -319,U

	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	RTS

