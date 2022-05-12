	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_202

	stb   <glb_alphaTiles
	LEAU 521,U

	LDA -40,U
	ANDA #$F0
	ORA #$08
	STA -40,U
	LDA #$78
	STA 40,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDA #$77
	STA 120,U
	LDA #$87
	STA 40,U
	LDA #$88
	STA -40,U
	LDA -120,U
	ANDA #$F0
	ORA #$08
	STA -120,U
	LEAU -200,U

	LDA ,U
	ANDA #$F0
	ORA #$07
	STA ,U
	RTS

