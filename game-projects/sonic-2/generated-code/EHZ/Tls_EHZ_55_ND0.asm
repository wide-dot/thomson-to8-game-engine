	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_55

	stb   <glb_alphaTiles
	LEAU 121,U

	LDA 120,U
	ANDA #$F0
	ORA #$07
	STA 120,U
	LDA #$77
	STA 40,U
	STA -40,U
	STA -120,U

	LDU <glb_screen_location_1
	LEAU 81,U

	LDA 80,U
	ANDA #$0F
	ORA #$70
	STA 80,U
	LDA #$77
	STA ,U
	STA -80,U
	RTS

