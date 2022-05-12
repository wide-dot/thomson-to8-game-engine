	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_20

	stb   <glb_alphaTiles
	LEAU 520,U

	LDA -40,U
	ANDA #$0F
	ORA #$80
	STA -40,U
	LDD 40,U
	ANDA #$0F
	ANDB #$F0
	ADDD #$8007
	STD 40,U

	LDU <glb_screen_location_1
	LEAU 520,U

	LDA 40,U
	ANDA #$0F
	ORA #$70
	STA 40,U
	LDA -40,U
	ANDA #$0F
	ORA #$70
	STA -40,U
	RTS

