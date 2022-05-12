	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_227

	stb   <glb_alphaTiles
	LEAU 440,U

	LDD 120,U
	LDA #$83
	ANDB #$0F
	ORB #$80
	STD 120,U
	LDD 40,U
	LDA #$84
	ANDB #$0F
	ORB #$80
	STD 40,U
	LDA -120,U
	ANDA #$0F
	ORA #$30
	STA -120,U
	LDA #$43
	STA -40,U

	LDU <glb_screen_location_1
	LEAU 521,U

	LDD 39,U
	LDA #$74
	ANDB #$0F
	ORB #$70
	STD 39,U
	LDD -41,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$7070
	STD -41,U
	RTS

