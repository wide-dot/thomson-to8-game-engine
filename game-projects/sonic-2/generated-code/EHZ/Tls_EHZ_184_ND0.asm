	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_184

	stb   <glb_alphaTiles
	LEAU 441,U

	LDD #$8787
	STD 119,U
	STD 39,U
	LDB #$88
	STD -41,U
	STD -121,U
	LEAU -241,U

	STB 40,U
	STB -40,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$7888
	STD -41,U
	LDB #$78
	STD 119,U
	STD 39,U
	LDD -121,U
	LDA #$88
	ANDB #$0F
	ORB #$70
	STD -121,U
	LEAU -201,U

	STA ,U
	RTS

