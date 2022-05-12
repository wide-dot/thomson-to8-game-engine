	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_88

	stb   <glb_alphaTiles
	LEAU 280,U

	LDA #$88
	STA -40,U
	STA -120,U
	LDA 120,U
	ANDA #$0F
	ORA #$70
	STA 120,U
	LDA 40,U
	ANDA #$0F
	ORA #$80
	STA 40,U
	LEAU -240,U

	LDA #$87
	STA 40,U
	LDD -40,U
	LDA #$87
	ANDB #$0F
	ORB #$70
	STD -40,U

	LDU <glb_screen_location_1
	LEAU 80,U

	LDA #$87
	STA ,U
	LDA 80,U
	ANDA #$0F
	ORA #$80
	STA 80,U
	LDA #$78
	STA -80,U
	RTS

