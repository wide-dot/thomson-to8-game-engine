	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_209

	stb   <glb_alphaTiles
	LEAU 441,U

	LDD #$8787
	STD 119,U
	LDA #$88
	STA -120,U
	STD 39,U
	STD -41,U
	LEAU -200,U

	LDA #$78
	STA ,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$8878
	STD -41,U
	STD -121,U
	LDA #$78
	STD 119,U
	STD 39,U
	LEAU -240,U

	LDA #$88
	STA 40,U
	STB -40,U
	RTS

