	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_102

	stb   <glb_alphaTiles
	LEAU 81,U

	LDA 80,U
	ANDA #$F0
	ORA #$07
	STA 80,U
	LDA 40,U
	ANDA #$F0
	ORA #$0d
	STA 40,U
	LDA #$dd
	STA -40,U
	LDA #$78
	STA ,U
	LDA #$87
	STA -80,U

	LDU <glb_screen_location_1
	LEAU 161,U

	LDA 120,U
	ANDA #$F0
	ORA #$0d
	STA 120,U
	LDA 80,U
	ANDA #$F0
	ORA #$08
	STA 80,U
	LDA #$dd
	STA 40,U
	STA -40,U
	LDA #$88
	STA ,U
	STA -80,U
	LDD -121,U
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD -121,U
	LEAU -160,U

	LDD -1,U
	ANDA #$F0
	ORA #$08
	LDB #$78
	STD -1,U
	RTS

