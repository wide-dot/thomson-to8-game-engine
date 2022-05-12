	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_40

	stb   <glb_alphaTiles
	LEAU 441,U

	LDD 119,U
	ANDA #$F0
	ORA #$06
	LDB #$77
	STD 119,U
	STB 40,U
	STB -40,U
	STB -120,U
	LEAU -200,U

	LDA ,U
	ANDA #$F0
	ORA #$07
	STA ,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDA #$77
	STA -120,U
	LDD -41,U
	ANDA #$F0
	ORA #$07
	LDB #$77
	STD -41,U
	LDD #$7777
	STD 119,U
	STD 39,U
	LEAU -280,U

	LDA -80,U
	ANDA #$F0
	ORA #$07
	STA -80,U
	LDA #$76
	STA ,U
	LDA #$67
	STA 80,U
	RTS

