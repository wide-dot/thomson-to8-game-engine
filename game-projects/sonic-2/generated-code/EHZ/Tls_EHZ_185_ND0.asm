	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_185

	stb   <glb_alphaTiles
	LEAU 480,U

	LDD ,U
	LDA #$88
	ANDB #$0F
	ORB #$70
	STD ,U
	LDD #$8788
	STD 80,U
	STA -80,U

	LDU <glb_screen_location_1
	LEAU 520,U

	LDA #$88
	STA -40,U
	LDD #$7888
	STD 40,U
	RTS

