	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_56

	stb   <glb_alphaTiles
	LEAU 121,U

	LDA #$77
	STA -40,U
	STA -120,U
	LDA 120,U
	ANDA #$0F
	ORA #$70
	STA 120,U
	LDA 40,U
	ANDA #$0F
	ORA #$70
	STA 40,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDA 40,U
	ANDA #$F0
	ORA #$07
	STA 40,U
	LDA -40,U
	ANDA #$F0
	ORA #$06
	STA -40,U
	LEAU -400,U

	LDA 40,U
	ANDA #$F0
	ORA #$03
	STA 40,U
	LDA -40,U
	ANDA #$F0
	ORA #$04
	STA -40,U
	RTS

