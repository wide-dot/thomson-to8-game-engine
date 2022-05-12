	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_flower2_1

	stb   <glb_alphaTiles
	LEAU 481,U

	LDA 120,U
	ANDA #$0F
	ORA #$d0
	STA 120,U
	LDA #$bb
	STA 80,U
	STA ,U
	LDA #$cb
	STA -80,U
	LDA #$dd
	STA 40,U
	STA -40,U
	STA -120,U
	LEAU -220,U

	LDA 60,U
	ANDA #$0F
	ORA #$b0
	STA 60,U
	LDD -21,U
	ANDA #$F0
	ANDB #$F0
	ADDD #$0b0b
	STD -21,U
	LDD -61,U
	ANDA #$F0
	ANDB #$F0
	ADDD #$0d0d
	STD -61,U

	LDU <glb_screen_location_1
	LEAU 480,U

	LDA 120,U
	ANDA #$F0
	ORA #$0d
	STA 120,U
	LDA 80,U
	ANDA #$F0
	ORA #$0b
	STA 80,U
	LDA -120,U
	ANDA #$F0
	ORA #$0d
	STA -120,U
	LDA #$bb
	STA ,U
	STA -80,U
	LDA #$dd
	STA 40,U
	STA -40,U
	LEAU -240,U

	LDA 80,U
	ANDA #$F0
	ORA #$0b
	STA 80,U
	LDD 40,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$d0d0
	STD 40,U
	LDD ,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$b0b0
	STD ,U
	LDD -40,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$d0d0
	STD -40,U
	LDD -80,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$b0b0
	STD -80,U
	RTS

