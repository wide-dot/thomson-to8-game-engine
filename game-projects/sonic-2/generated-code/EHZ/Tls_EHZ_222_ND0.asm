	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_222

	stb   <glb_alphaTiles
	LEAU 480,U

	LDA #$44
	STA 80,U
	STA ,U
	LDA -80,U
	ANDA #$0F
	ORA #$40
	STA -80,U

	LDU <glb_screen_location_1
	LEAU 560,U

	LDA ,U
	ANDA #$0F
	ORA #$40
	STA ,U
	RTS

