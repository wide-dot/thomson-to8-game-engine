	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_86

	stb   <glb_alphaTiles
	LEAU 200,U

	LDA #$88
	STA 40,U
	STA -40,U
	LDA #$87
	STA -120,U
	LDA 120,U
	ANDA #$0F
	ORA #$70
	STA 120,U
	LEAU -199,U

	LDD #$8787
	STD -1,U

	LDU <glb_screen_location_1
	LEAU 80,U

	LDA 80,U
	ANDA #$0F
	ORA #$80
	STA 80,U
	LDA #$88
	STA ,U
	LDA #$78
	STA -80,U
	RTS

