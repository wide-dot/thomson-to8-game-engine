	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_54

	stb   <glb_alphaTiles
	LEAU 120,U

	LDA 120,U
	ANDA #$F0
	ORA #$07
	STA 120,U
	LDA 40,U
	ANDA #$F0
	ORA #$07
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
	LEAU 440,U

	LDA 120,U
	ANDA #$F0
	ORA #$07
	STA 120,U
	LDA 40,U
	ANDA #$F0
	ORA #$07
	STA 40,U
	LDA -40,U
	ANDA #$0F
	ORA #$70
	STA -40,U
	LDA -120,U
	ANDA #$0F
	ORA #$70
	STA -120,U
	RTS

