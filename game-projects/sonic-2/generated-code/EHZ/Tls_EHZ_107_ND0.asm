	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_107

	stb   <glb_alphaTiles
	LEAU 61,U

	LDA 60,U
	ANDA #$F0
	ORA #$0d
	STA 60,U
	LDA 20,U
	ANDA #$F0
	ORA #$08
	STA 20,U
	LDA #$dd
	STA -20,U
	LDA #$88
	STA -60,U

	LDU <glb_screen_location_1
	LEAU 241,U

	LDA 120,U
	ANDA #$F0
	ORA #$0d
	STA 120,U
	LDA 80,U
	ANDA #$F0
	ORA #$08
	STA 80,U
	LDA 40,U
	ANDA #$F0
	ORA #$0d
	STA 40,U
	LDA #$78
	STA ,U
	LDA #$dd
	STA -40,U
	STA -120,U
	LDA #$87
	STA -80,U
	LEAU -200,U

	LDA #$dd
	STA ,U
	LDA #$77
	STA 40,U
	STA -40,U
	RTS

