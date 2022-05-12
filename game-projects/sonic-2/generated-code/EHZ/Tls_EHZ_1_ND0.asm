	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_1

	stb   <glb_alphaTiles
	LEAU 521,U

	LDA -40,U
	ANDA #$0F
	ORA #$80
	STA -40,U
	LDD 39,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0880
	STD 39,U

	LDU <glb_screen_location_1
	LEAU 521,U

	LDD 39,U
	LDA #$78
	ANDB #$0F
	ORB #$70
	STD 39,U
	LDA -40,U
	ANDA #$0F
	ORA #$70
	STA -40,U
	RTS

