	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_90

	stb   <glb_alphaTiles
	LEAU 440,U

	LDA #$77
	STA 120,U
	STA 40,U
	LDA #$78
	STA -40,U
	STA -120,U
	LEAU -320,U

	LDA #$d7
	STA 40,U
	STA -40,U
	STA -120,U
	LDA #$78
	STA 120,U

	LDU <glb_screen_location_1
	LEAU 80,U

	LDA 80,U
	ANDA #$0F
	ORA #$70
	STA 80,U
	LDA ,U
	ANDA #$0F
	ORA #$80
	STA ,U
	LDA -80,U
	ANDA #$0F
	ORA #$80
	STA -80,U
	RTS

