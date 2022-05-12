	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_282

	stb   <glb_alphaTiles
	LEAU 41,U

	LDA 40,U
	ANDA #$F0
	ORA #$03
	STA 40,U
	LDA ,U
	ANDA #$F0
	ORA #$0d
	STA ,U
	LDA #$33
	STA -40,U

	LDU <glb_screen_location_1
	LEAU 101,U

	LDA #$dd
	STA 20,U
	STA -60,U
	LDA #$34
	STA 60,U
	LDA #$33
	STA -20,U
	STA -100,U
	LDA 100,U
	ANDA #$F0
	ORA #$0d
	STA 100,U
	RTS

