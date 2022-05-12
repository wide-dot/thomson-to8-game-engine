	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_231

	stb   <glb_alphaTiles
	LEAU 541,U

	LDA -20,U
	ANDA #$F0
	ORA #$0d
	STA -20,U
	LDA -60,U
	ANDA #$F0
	ORA #$08
	STA -60,U
	LDA #$78
	STA 20,U
	LDA #$dd
	STA 60,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDA #$77
	STA 80,U
	LDA #$dd
	STA 120,U
	STA 40,U
	STA -40,U
	STA -120,U
	LDA #$87
	STA ,U
	LDA #$88
	STA -80,U
	LEAU -200,U

	LDA 40,U
	ANDA #$F0
	ORA #$08
	STA 40,U
	LDA ,U
	ANDA #$F0
	ORA #$0d
	STA ,U
	LDA -40,U
	ANDA #$F0
	ORA #$07
	STA -40,U
	RTS

