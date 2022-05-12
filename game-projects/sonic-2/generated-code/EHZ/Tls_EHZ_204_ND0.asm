	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_204

	stb   <glb_alphaTiles
	LEAU 521,U

	LDA -40,U
	ANDA #$F0
	ORA #$08
	STA -40,U
	LDA #$88
	STA 40,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD 119,U
	ANDA #$F0
	ORA #$07
	LDB #$78
	STD 119,U
	LDA #$88
	STA 40,U
	STA -40,U
	LDA -120,U
	ANDA #$F0
	ORA #$07
	STA -120,U
	RTS

