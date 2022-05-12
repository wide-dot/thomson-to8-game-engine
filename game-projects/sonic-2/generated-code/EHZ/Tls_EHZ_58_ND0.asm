	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_58

	stb   <glb_alphaTiles
	LEAU 440,U

	LDA #$77
	STA 40,U
	LDA 120,U
	ANDA #$F0
	ORA #$07
	STA 120,U
	LDA -40,U
	ANDA #$0F
	ORA #$70
	STA -40,U
	LDA -120,U
	ANDA #$0F
	ORA #$60
	STA -120,U
	LEAU -320,U

	LDA #$43
	STA -40,U
	LDA #$44
	STA -120,U
	LDA 120,U
	ANDA #$0F
	ORA #$40
	STA 120,U
	LDA 40,U
	ANDA #$0F
	ORA #$40
	STA 40,U

	LDU <glb_screen_location_1
	RTS

