	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_171

	stb   <glb_alphaTiles
	LEAU 441,U

	LDD #$8754
	STD -121,U
	LDB #$87
	STD 119,U
	STD 39,U
	STD -41,U
	LEAU -320,U

	LDA #$84
	STA -40,U
	LDA #$54
	STA 40,U
	STA -120,U
	LDD 119,U
	ANDA #$F0
	ORA #$07
	LDB #$44
	STD 119,U

	LDU <glb_screen_location_1
	LEAU 440,U

	LDA #$78
	STA -120,U
	LDD #$7838
	STD -40,U
	LDB #$78
	STD 120,U
	STD 40,U
	LEAU -320,U

	LDD 40,U
	LDA #$44
	ANDB #$0F
	ORB #$30
	STD 40,U
	LDD -40,U
	LDA #$44
	ANDB #$0F
	ORB #$30
	STD -40,U
	LDA #$38
	STA 120,U
	LDA #$34
	STA -120,U
	RTS
