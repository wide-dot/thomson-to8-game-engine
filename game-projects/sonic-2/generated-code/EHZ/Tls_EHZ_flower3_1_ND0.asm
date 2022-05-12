	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_flower3_1

	stb   <glb_alphaTiles
	LEAU 361,U

	LDA -40,U
	ANDA #$0F
	ORA #$c0
	STA -40,U
	LDD 119,U
	ANDA #$F0
	ANDB #$F0
	ADDD #$0c0c
	STD 119,U
	LDD 39,U
	ANDA #$F0
	ANDB #$F0
	ADDD #$0c0b
	STD 39,U
	LDD -121,U
	ANDA #$F0
	ORA #$0b
	LDB #$bb
	STD -121,U
	LEAU -240,U

	LDD 39,U
	ANDA #$F0
	ANDB #$F0
	ADDD #$0c0b
	STD 39,U
	LDD -41,U
	ANDA #$F0
	ANDB #$F0
	ADDD #$0c0c
	STD -41,U

	LDU <glb_screen_location_1
	LEAU 361,U

	LDA -41,U
	ANDA #$F0
	ORA #$0b
	STA -41,U
	LDD 119,U
	LDA #$bb
	ANDB #$0F
	ORB #$c0
	STD 119,U
	LDD 39,U
	LDA #$bb
	ANDB #$0F
	ORB #$c0
	STD 39,U
	LDD -121,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD -121,U
	LEAU -240,U

	LDD 39,U
	LDA #$bb
	ANDB #$0F
	ORB #$b0
	STD 39,U
	LDD -41,U
	LDA #$cb
	ANDB #$0F
	ORB #$c0
	STD -41,U
	RTS

