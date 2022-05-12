	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_flower1_1

	stb   <glb_alphaTiles
	LEAU 441,U

	LDA 120,U
	ANDA #$0F
	ORA #$30
	STA 120,U
	LDA #$cb
	STA -120,U
	LDA #$b3
	STA 40,U
	LDA #$bb
	STA -40,U
	LEAU -320,U

	LDA 40,U
	ANDA #$0F
	ORA #$b0
	STA 40,U
	LDA -40,U
	ANDA #$0F
	ORA #$b0
	STA -40,U
	LDA -120,U
	ANDA #$F0
	ORA #$03
	STA -120,U
	LDD 119,U
	ANDA #$F0
	ORA #$03
	LDB #$cc
	STD 119,U

	LDU <glb_screen_location_1
	LEAU 440,U

	LDA 120,U
	ANDA #$F0
	ORA #$03
	STA 120,U
	LDA 40,U
	ANDA #$F0
	ORA #$03
	STA 40,U
	LDA #$3b
	STA -40,U
	LDD -120,U
	LDA #$bb
	ANDB #$0F
	ORB #$30
	STD -120,U
	LEAU -320,U

	LDA #$3b
	STA -120,U
	LDD 120,U
	LDA #$bc
	ANDB #$0F
	ORB #$30
	STD 120,U
	LDD 40,U
	LDA #$bb
	ANDB #$0F
	ORB #$30
	STD 40,U
	LDD -40,U
	LDA #$b3
	ANDB #$0F
	ORB #$30
	STD -40,U
	RTS

