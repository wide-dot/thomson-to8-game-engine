	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_201

	stb   <glb_alphaTiles
	LEAU 441,U

	LDA #$87
	STA -120,U
	LDA #$7d
	STA 120,U
	STA 40,U
	LDA #$77
	STA -40,U
	LEAU -320,U

	LDA #$87
	STA 120,U
	LDA #$78
	STA 40,U
	LDA -40,U
	ANDA #$F0
	ORA #$08
	STA -40,U
	LDA -120,U
	ANDA #$F0
	ORA #$08
	STA -120,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$87dd
	STD 119,U
	LDA #$78
	STD 39,U
	LDD -41,U
	ANDA #$F0
	ORA #$08
	LDB #$dd
	STD -41,U
	LDD -121,U
	ANDA #$F0
	ORA #$07
	LDB #$7d
	STD -121,U
	LEAU -320,U

	STB 120,U
	LDA #$77
	STA 40,U
	STA -40,U
	STA -120,U
	RTS

