	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_234

	stb   <glb_alphaTiles
	LEAU 521,U

	LDA #$88
	STA 40,U
	LDA #$dd
	STA 80,U
	STA ,U
	LDA -40,U
	ANDA #$F0
	ORA #$08
	STA -40,U
	LDA -80,U
	ANDA #$F0
	ORA #$0d
	STA -80,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD 119,U
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD 119,U
	LDD 79,U
	ANDA #$F0
	ORA #$07
	LDB #$78
	STD 79,U
	LDA #$88
	STA ,U
	STA -80,U
	LDA #$dd
	STA 40,U
	STA -40,U
	LDA -120,U
	ANDA #$F0
	ORA #$0d
	STA -120,U
	LEAU -160,U

	LDA ,U
	ANDA #$F0
	ORA #$07
	STA ,U
	RTS

