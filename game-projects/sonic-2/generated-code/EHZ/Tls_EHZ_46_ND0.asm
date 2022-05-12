	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_46

	stb   <glb_alphaTiles
	LEAU 481,U

	LDA -80,U
	ANDA #$F0
	ORA #$07
	STA -80,U
	LDA #$76
	STA ,U
	LDD 79,U
	ANDA #$F0
	ORA #$07
	LDB #$68
	STD 79,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$7788
	STD 119,U
	LDA -120,U
	ANDA #$F0
	ORA #$06
	STA -120,U
	LDA #$68
	STA -40,U
	LDD 39,U
	ANDA #$F0
	ORA #$07
	LDB #$88
	STD 39,U
	RTS

