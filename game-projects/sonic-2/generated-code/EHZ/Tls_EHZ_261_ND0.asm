	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_261

	stb   <glb_alphaTiles
	LEAU 521,U

	LDA #$4d
	STA 40,U
	STA -40,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDA #$dd
	STA ,U
	STA -80,U
	LDD #$d4dd
	STD 79,U
	RTS

