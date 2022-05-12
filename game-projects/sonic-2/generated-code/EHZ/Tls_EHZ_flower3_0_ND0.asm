	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_flower3_0

	stb   <glb_alphaTiles
	LEAU 441,U

	LDA 120,U
	ANDA #$0F
	ORA #$c0
	STA 120,U
	LDD #$cbcb
	STD -121,U
	LDD -41,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0cb0
	STD -41,U
	LDA #$bb
	STA 40,U
	LEAU -320,U

	LDA 40,U
	ANDA #$0F
	ORA #$b0
	STA 40,U
	LDA -120,U
	ANDA #$0F
	ORA #$c0
	STA -120,U
	LDD 119,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0cb0
	STD 119,U
	LDA #$bc
	STA -40,U

	LDU <glb_screen_location_1
	LEAU 440,U

	LDD #$bbbc
	STD -120,U
	LDA 120,U
	ANDA #$F0
	ORA #$0c
	STA 120,U
	LDA 40,U
	ANDA #$F0
	ORA #$0c
	STA 40,U
	LDA -39,U
	ANDA #$0F
	ORA #$b0
	STA -39,U
	LEAU -280,U

	LDD #$b3cc
	STD 80,U
	LDA ,U
	ANDA #$F0
	ORA #$0b
	STA ,U
	LDA -80,U
	ANDA #$F0
	ORA #$0c
	STA -80,U
	RTS

