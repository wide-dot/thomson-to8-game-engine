	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_284

	stb   <glb_alphaTiles
	LEAU 520,U

	LDA #$dd
	STA 80,U
	STA ,U
	LDA #$44
	STA 40,U
	LDA #$43
	STA -40,U
	LDA -80,U
	ANDA #$0F
	ORA #$d0
	STA -80,U

	LDU <glb_screen_location_1
	LEAU 580,U

	LDA 20,U
	ANDA #$0F
	ORA #$d0
	STA 20,U
	LDA -20,U
	ANDA #$0F
	ORA #$30
	STA -20,U
	RTS

