	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_254

	stb   <glb_alphaTiles

	LDU <glb_screen_location_1
	LEAU 521,U

	LDA -40,U
	ANDA #$F0
	ORA #$0d
	STA -40,U
	LDA #$33
	STA 40,U
	RTS
