	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_4

	stb   <glb_alphaTiles
	LEAU 560,U

	LDA ,U
	ANDA #$0F
	ORA #$80
	STA ,U

	LDU <glb_screen_location_1
	LEAU 561,U

	LDD -1,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$7070
	STD -1,U
	RTS

