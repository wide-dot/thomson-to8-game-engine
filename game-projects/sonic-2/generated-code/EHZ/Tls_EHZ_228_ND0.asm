	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_228

	stb   <glb_alphaTiles
	LEAU 541,U

	LDD 59,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$d0d0
	STD 59,U
	LDD 19,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$8080
	STD 19,U
	LDD -21,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$d0d0
	STD -21,U
	LDD -61,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$8080
	STD -61,U

	LDU <glb_screen_location_1
	LEAU 541,U

	LDD 19,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$7070
	STD 19,U
	LDD -21,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$d0d0
	STD -21,U
	LDD -61,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$7070
	STD -61,U
	LDD #$dddd
	STD 59,U
	RTS

