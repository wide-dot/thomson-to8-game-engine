	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_351

	stb   <glb_alphaTiles
	LEAU 561,U

	LDA ,U
	ANDA #$F0
	ORA #$03
	STA ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDA -80,U
	ANDA #$F0
	ORA #$04
	STA -80,U
	LDA #$33
	STA 80,U
	LDA #$35
	STA ,U
	RTS

