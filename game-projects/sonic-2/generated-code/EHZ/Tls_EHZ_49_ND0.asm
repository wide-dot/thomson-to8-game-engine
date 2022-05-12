	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_49

	stb   <glb_alphaTiles

	LDU <glb_screen_location_1
	LEAU 81,U

	LDA 80,U
	ANDA #$F0
	ORA #$06
	STA 80,U
	LDA ,U
	ANDA #$F0
	ORA #$07
	STA ,U
	LDA #$76
	STA -80,U
	RTS

