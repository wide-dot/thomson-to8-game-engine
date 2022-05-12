	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_72

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

	LDD #$7878
	STD 119,U
	LDD 39,U
	ANDA #$F0
	ORA #$08
	LDB #$78
	STD 39,U
	LDD -41,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0870
	STD -41,U
	LDA -120,U
	ANDA #$0F
	ORA #$70
	STA -120,U
	RTS

