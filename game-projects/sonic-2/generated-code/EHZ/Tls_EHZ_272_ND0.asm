	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_272

	stb   <glb_alphaTiles
	LEAU 80,U

	LDA #$33
	STA ,U
	LDA #$43
	STA 80,U
	LDD #$ddd4
	STD -80,U

	LDU <glb_screen_location_1
	LEAU 40,U

	LDA #$d3
	STA 40,U
	LDA #$dd
	STA -40,U
	RTS

