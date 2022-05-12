	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_175

	stb   <glb_alphaTiles
	LEAU 560,U

	LDA #$87
	STA ,U

	LDU <glb_screen_location_1
	LEAU 560,U

	LDA ,U
	ANDA #$F0
	ORA #$08
	STA ,U
	RTS

