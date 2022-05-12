	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_372

	stb   <glb_alphaTiles
	LEAU 1,U

	LDA ,U
	ANDA #$F0
	ORA #$04
	STA ,U

	LDU <glb_screen_location_1
	LEAU 81,U

	LDA #$dd
	STA -40,U
	LDA #$45
	STA ,U
	LDA 80,U
	ANDA #$F0
	ORA #$04
	STA 80,U
	LDA 40,U
	ANDA #$F0
	ORA #$0d
	STA 40,U
	LDA #$55
	STA -80,U
	RTS

