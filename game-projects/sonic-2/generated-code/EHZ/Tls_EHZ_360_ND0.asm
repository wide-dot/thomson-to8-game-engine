	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_360

	stb   <glb_alphaTiles
	LEAU 80,U

	LDA 80,U
	ANDA #$0F
	ORA #$d0
	STA 80,U
	LDA #$3d
	STA ,U
	LDA #$33
	STA -80,U

	LDU <glb_screen_location_1
	LDA ,U
	ANDA #$0F
	ORA #$30
	STA ,U
	RTS

