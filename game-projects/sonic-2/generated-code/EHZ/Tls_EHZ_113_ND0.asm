	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_113

	stb   <glb_alphaTiles
	LEAU 441,U

	LDA #$87
	STA 120,U
	STA 40,U
	LDA -40,U
	ANDA #$0F
	ORA #$80
	STA -40,U
	LDA -120,U
	ANDA #$0F
	ORA #$80
	STA -120,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDA #$78
	STA 40,U
	LDD 119,U
	ANDA #$0F
	ORA #$70
	LDB #$78
	STD 119,U
	LDA -40,U
	ANDA #$0F
	ORA #$70
	STA -40,U
	LDA -120,U
	ANDA #$0F
	ORA #$70
	STA -120,U
	RTS

