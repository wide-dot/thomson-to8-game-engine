	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_394

	stb   <glb_alphaTiles
	LEAU 441,U

	LDD #$8787
	STD 119,U
	STD 39,U
	LDB #$88
	STD -41,U
	LDA #$88
	STD -121,U
	LEAU -281,U

	LDA #$87
	STA -80,U
	LDD #$8868
	STD ,U
	LDB #$88
	STD 80,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$7878
	STD 119,U
	STD 39,U
	STD -41,U
	LDD #$8888
	STD -121,U
	LEAU -240,U

	LDD #$8786
	STD -41,U
	LDD #$8888
	STD 39,U
	RTS

