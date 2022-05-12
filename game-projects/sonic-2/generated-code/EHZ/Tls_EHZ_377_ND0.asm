	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_377

	stb   <glb_alphaTiles
	LEAU 1,U

	LDA ,U
	ANDA #$F0
	ORA #$03
	STA ,U

	LDU <glb_screen_location_1
	LEAU 81,U

	LDA 80,U
	ANDA #$F0
	ORA #$03
	STA 80,U
	LDA 40,U
	ANDA #$F0
	ORA #$0d
	STA 40,U
	LDA #$33
	STA ,U
	STA -80,U
	LDA #$dd
	STA -40,U
	RTS

