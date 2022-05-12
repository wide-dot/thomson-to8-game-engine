	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_205

	stb   <glb_alphaTiles
	LEAU 441,U

	LDD #$877d
	STD 119,U
	STD 39,U
	LDB #$77
	STD -41,U
	STD -121,U
	LEAU -320,U

	LDA #$78
	STD 119,U
	STB 40,U
	LDA #$87
	STA -40,U
	STA -120,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$78d3
	STD 119,U
	LDB #$dd
	STD 39,U
	STD -41,U
	LDB #$77
	STD -121,U
	LEAU -320,U

	LDA #$88
	STD 39,U
	LDA #$78
	STD 119,U
	LDD -41,U
	ANDA #$F0
	ORA #$08
	LDB #$77
	STD -41,U
	LDD -121,U
	ANDA #$F0
	ORA #$07
	LDB #$77
	STD -121,U
	RTS

