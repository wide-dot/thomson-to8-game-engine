	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_361

	stb   <glb_alphaTiles
	LEAU 561,U

	LDA #$3d
	STA ,U

	LDU <glb_screen_location_1
	LEAU 521,U

	LDD 39,U
	ANDA #$F0
	ORA #$03
	LDB #$dd
	STD 39,U
	LDA #$34
	STA -40,U
	RTS

