	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_115

	stb   <glb_alphaTiles
	LEAU 441,U

	LDD #$8787
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LEAU -320,U

	STD 119,U
	LDD 39,U
	ANDA #$0F
	ORA #$80
	LDB #$87
	STD 39,U
	LDA -120,U
	ANDA #$0F
	ORA #$80
	STA -120,U
	LDD -41,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$8080
	STD -41,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$7878
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LEAU -320,U

	STD 119,U
	LDD 39,U
	ANDA #$0F
	ORA #$70
	LDB #$78
	STD 39,U
	LDD -41,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$7070
	STD -41,U
	LDA -120,U
	ANDA #$0F
	ORA #$70
	STA -120,U
	RTS
