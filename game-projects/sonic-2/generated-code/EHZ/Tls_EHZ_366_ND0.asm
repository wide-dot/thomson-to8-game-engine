	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_366

	stb   <glb_alphaTiles
	LEAU 40,U

	LDA #$43
	STA -40,U
	LDA 40,U
	ANDA #$0F
	ORA #$30
	STA 40,U

	LDU <glb_screen_location_1
	LDA ,U
	ANDA #$0F
	ORA #$d0
	STA ,U
	RTS

