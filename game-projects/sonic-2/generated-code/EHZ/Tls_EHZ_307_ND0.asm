	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_307

	stb   <glb_alphaTiles
	LEAU 441,U

	LDD #$87d7
	STD -121,U
	LDD #$77dd
	STD 119,U
	STD 39,U
	LDB #$d7
	STD -41,U
	LEAU -320,U

	LDD #$8877
	STD 39,U
	LDA #$87
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

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$7d78
	STD -41,U
	STD -121,U
	LDB #$d8
	STD 39,U
	LDA #$dd
	STD 119,U
	LEAU -320,U

	LDD #$7778
	STD 39,U
	STD -41,U
	LDA #$7d
	STD 119,U
	LDA #$87
	STD -121,U
	RTS

