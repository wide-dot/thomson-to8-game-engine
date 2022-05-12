	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_273

	stb   <glb_alphaTiles
	LEAU 41,U

	LDA #$dd
	STA ,U
	STA -40,U
	LDA 40,U
	ANDA #$F0
	ORA #$03
	STA 40,U

	LDU <glb_screen_location_1
	LEAU 81,U

	LDA 80,U
	ANDA #$F0
	ORA #$03
	STA 80,U
	LDA #$44
	STA ,U
	LDA #$dd
	STA 40,U
	STA -40,U
	LDD -81,U
	ANDA #$F0
	ORA #$04
	LDB #$44
	STD -81,U
	RTS

