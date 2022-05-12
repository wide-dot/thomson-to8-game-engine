	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_3

	stb   <glb_alphaTiles
	LEAU 520,U

	LDA -40,U
	ANDA #$F0
	ORA #$07
	STA -40,U
	LDA #$87
	STA 40,U

	LDU <glb_screen_location_1
	LEAU 560,U

	LDA ,U
	ANDA #$F0
	ORA #$08
	STA ,U
	RTS

