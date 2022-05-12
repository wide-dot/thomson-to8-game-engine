	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_200

	stb   <glb_alphaTiles
	LEAU 561,U

	LDA ,U
	ANDA #$F0
	ORA #$07
	STA ,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDA #$87
	STA 120,U
	STA 40,U
	STA -40,U
	LDA #$77
	STA -120,U
	LEAU -320,U

	LDA 40,U
	ANDA #$F0
	ORA #$07
	STA 40,U
	LDA -40,U
	ANDA #$F0
	ORA #$07
	STA -40,U
	LDA -120,U
	ANDA #$F0
	ORA #$07
	STA -120,U
	LDA #$77
	STA 120,U
	RTS

