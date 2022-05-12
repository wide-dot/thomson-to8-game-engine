	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_flower1_0

	stb   <glb_alphaTiles
	LEAU 441,U

	LDA 120,U
	ANDA #$0F
	ORA #$30
	STA 120,U
	LDA #$3b
	STA -120,U
	LDD -41,U
	ANDA #$F0
	ORA #$03
	LDB #$cc
	STD -41,U
	LDA #$b3
	STA 40,U
	LEAU -200,U

	LDD -1,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0bc0
	STD -1,U

	LDU <glb_screen_location_1
	LEAU 440,U

	LDA #$3b
	STA 40,U
	LDA #$33
	STA -120,U
	LDA 120,U
	ANDA #$F0
	ORA #$03
	STA 120,U
	LDD -40,U
	LDA #$bc
	ANDB #$0F
	ORB #$b0
	STD -40,U
	LEAU -199,U

	LDD -1,U
	ANDA #$F0
	ORA #$0b
	LDB #$bb
	STD -1,U
	RTS

