	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_2

	stb   <glb_alphaTiles
	LEAU 521,U

	LDD 39,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$8080
	STD 39,U
	LDD -41,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$8080
	STD -41,U

	LDU <glb_screen_location_1
	LEAU 521,U

	LDD 39,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$7070
	STD 39,U
	LDD -41,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$7070
	STD -41,U
	RTS

