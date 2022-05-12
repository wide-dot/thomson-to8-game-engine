	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_117

	stb   <glb_alphaTiles
	LEAU 481,U

	LDD -1,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$8080
	STD -1,U
	LDD 79,U
	ANDA #$0F
	ORA #$80
	LDB #$87
	STD 79,U
	LDA -80,U
	ANDA #$0F
	ORA #$80
	STA -80,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDA -80,U
	ANDA #$0F
	ORA #$70
	STA -80,U
	LDD -1,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$7070
	STD -1,U
	LDD 79,U
	ANDA #$0F
	ORA #$70
	LDB #$78
	STD 79,U
	RTS

