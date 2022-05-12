	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_91

	stb   <glb_alphaTiles
	LEAU 440,U

	LDA 120,U
	ANDA #$0F
	ORA #$40
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
	ORA #$40
	STA -120,U
	LEAU -320,U

	LDA 120,U
	ANDA #$0F
	ORA #$70
	STA 120,U
	LDA 40,U
	ANDA #$0F
	ORA #$70
	STA 40,U
	LDA -40,U
	ANDA #$0F
	ORA #$70
	STA -40,U
	LDA -120,U
	ANDA #$0F
	ORA #$70
	STA -120,U

	LDU <glb_screen_location_1
	RTS

