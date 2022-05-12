	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_281

	stb   <glb_alphaTiles
	LEAU 120,U

	LDA 120,U
	ANDA #$0F
	ORA #$40
	STA 120,U
	LDA #$33
	STA -120,U
	LDA #$54
	STA 40,U
	LDA #$53
	STA -40,U

	LDU <glb_screen_location_1
	LEAU 40,U

	LDA #$33
	STA -40,U
	LDA 40,U
	ANDA #$0F
	ORA #$30
	STA 40,U
	RTS

