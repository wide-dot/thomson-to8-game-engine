	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_355

	stb   <glb_alphaTiles
	LEAU 80,U

	LDA #$55
	STA ,U
	STA -80,U
	LDA 80,U
	ANDA #$0F
	ORA #$30
	STA 80,U

	LDU <glb_screen_location_1
	LDA ,U
	ANDA #$0F
	ORA #$50
	STA ,U
	RTS

