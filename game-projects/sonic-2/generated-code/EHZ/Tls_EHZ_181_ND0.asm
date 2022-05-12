	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_181

	stb   <glb_alphaTiles
	LEAU 440,U

	LDA -120,U
	ANDA #$0F
	ORA #$80
	STA -120,U
	LDA #$88
	STA 40,U
	STA -40,U
	LDD 120,U
	LDA #$87
	ANDB #$0F
	ORB #$70
	STD 120,U

	LDU <glb_screen_location_1
	LEAU 520,U

	LDA #$78
	STA 40,U
	LDA #$87
	STA -40,U
	RTS

