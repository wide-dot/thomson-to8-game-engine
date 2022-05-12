	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_356

	stb   <glb_alphaTiles
	LEAU 481,U

	LDA -80,U
	ANDA #$F0
	ORA #$04
	STA -80,U
	LDA #$44
	STA 80,U
	STA ,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDA #$43
	STA 40,U
	LDD #$3443
	STD 119,U
	LDA #$33
	STA -40,U
	STA -120,U
	RTS

