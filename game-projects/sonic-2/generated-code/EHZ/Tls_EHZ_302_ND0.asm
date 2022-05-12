	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_302

	stb   <glb_alphaTiles
	LEAU 441,U

	LDD #$8787
	STD 119,U
	STD 39,U
	LDD -41,U
	ANDA #$0F
	ORA #$80
	LDB #$87
	STD -41,U
	LDD -121,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$8080
	STD -121,U
	LEAU -200,U

	LDA ,U
	ANDA #$0F
	ORA #$80
	STA ,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$7878
	STD 119,U
	STD 39,U
	LDD -41,U
	ANDA #$0F
	ORA #$70
	LDB #$78
	STD -41,U
	LDD -121,U
	ANDA #$0F
	ORA #$70
	LDB #$78
	STD -121,U
	LEAU -200,U

	LDA ,U
	ANDA #$0F
	ORA #$70
	STA ,U
	RTS

