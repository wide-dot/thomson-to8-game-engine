	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_219

	stb   <glb_alphaTiles
	LEAU 440,U

	LDA #$34
	STA 120,U
	LDA #$44
	STA 40,U
	STA -40,U
	LDA #$43
	STA -120,U
	LEAU -200,U

	LDA ,U
	ANDA #$0F
	ORA #$40
	STA ,U

	LDU <glb_screen_location_1
	LEAU 520,U

	LDA #$43
	STA 40,U
	LDA -40,U
	ANDA #$0F
	ORA #$30
	STA -40,U
	RTS

