	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_382

	stb   <glb_alphaTiles
	LEAU 1,U

	LDA ,U
	ANDA #$F0
	ORA #$03
	STA ,U

	LDU <glb_screen_location_1
	LEAU 61,U

	LDA #$34
	STA 20,U
	LDA 60,U
	ANDA #$F0
	ORA #$0d
	STA 60,U
	LDA #$dd
	STA -20,U
	LDA #$44
	STA -60,U
	RTS

