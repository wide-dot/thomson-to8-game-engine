	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_178

	stb   <glb_alphaTiles
	LEAU 440,U

	LDA #$87
	STA 120,U
	STA 40,U
	LDA #$88
	STA -40,U
	LDA #$87
	STA -120,U
	LEAU -200,U

	LDA ,U
	ANDA #$0F
	ORA #$80
	STA ,U

	LDU <glb_screen_location_1
	LEAU 480,U

	LDA ,U
	ANDA #$0F
	ORA #$80
	STA ,U
	LDA -80,U
	ANDA #$0F
	ORA #$70
	STA -80,U
	LDA #$88
	STA 80,U
	RTS

