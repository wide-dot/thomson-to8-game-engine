	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_50

	stb   <glb_alphaTiles
	LEAU 481,U

	LDA #$77
	STA 80,U
	LDA ,U
	ANDA #$F0
	ORA #$07
	STA ,U
	LDA -80,U
	ANDA #$F0
	ORA #$07
	STA -80,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDA #$77
	STA 120,U
	STA 40,U
	STA -40,U
	STA -120,U
	LEAU -280,U

	LDA ,U
	ANDA #$F0
	ORA #$07
	STA ,U
	LDA -80,U
	ANDA #$F0
	ORA #$07
	STA -80,U
	LDA #$77
	STA 80,U
	RTS

