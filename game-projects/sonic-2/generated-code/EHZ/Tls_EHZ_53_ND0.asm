	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_53

	stb   <glb_alphaTiles
	LEAU 440,U

	LDA #$44
	STA 120,U
	LDA 40,U
	ANDA #$0F
	ORA #$40
	STA 40,U
	LDA -40,U
	ANDA #$0F
	ORA #$40
	STA -40,U
	LDA -120,U
	ANDA #$0F
	ORA #$30
	STA -120,U
	LEAU -320,U

	LDA 120,U
	ANDA #$0F
	ORA #$30
	STA 120,U
	LDA #$66
	STA -120,U
	LDA #$46
	STA 40,U
	STA -40,U

	LDU <glb_screen_location_1
	LEAU 40,U

	LDA 40,U
	ANDA #$0F
	ORA #$60
	STA 40,U
	LDD -40,U
	ANDA #$0F
	ORA #$60
	LDB #$77
	STD -40,U
	RTS

