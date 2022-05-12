	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_82

	stb   <glb_alphaTiles
	LEAU 80,U

	LDA #$88
	STA 80,U
	LDD #$8788
	STD ,U
	LDB #$87
	STD -80,U

	LDU <glb_screen_location_1
	LEAU 80,U

	LDD #$7878
	STD -80,U
	LDD #$8877
	STD ,U
	LDA 80,U
	ANDA #$0F
	ORA #$70
	STA 80,U
	RTS

