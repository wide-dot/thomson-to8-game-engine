	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_92

	stb   <glb_alphaTiles
	LEAU 440,U

	LDA #$d4
	STA 120,U
	STA 40,U
	STA -40,U
	LDA #$34
	STA -120,U
	LEAU -320,U

	LDA #$44
	STA 40,U
	LDA #$43
	STA -40,U
	LDA #$34
	STA 120,U
	LDA -120,U
	ANDA #$0F
	ORA #$40
	STA -120,U

	LDU <glb_screen_location_1
	LEAU 480,U

	LDA 80,U
	ANDA #$0F
	ORA #$40
	STA 80,U
	LDA ,U
	ANDA #$0F
	ORA #$40
	STA ,U
	LDA -80,U
	ANDA #$0F
	ORA #$30
	STA -80,U
	RTS

