	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_258

	stb   <glb_alphaTiles
	LEAU 441,U

	LDD #$5355
	STD 119,U
	LDA #$33
	STD 39,U
	LDD -121,U
	ANDA #$F0
	ORA #$03
	LDB #$54
	STD -121,U
	LDD #$3333
	STD -41,U
	LEAU -320,U

	LDA #$55
	STA 120,U
	STA 40,U
	LDA #$45
	STA -40,U
	LDA -120,U
	ANDA #$F0
	ORA #$03
	STA -120,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$3553
	STD 119,U
	LDD #$3333
	STD 39,U
	STD -41,U
	STD -121,U
	LEAU -320,U

	LDD #$3543
	STD 119,U
	STB -40,U
	LDD 39,U
	ANDA #$F0
	ORA #$04
	LDB #$54
	STD 39,U
	LDA #$33
	STA -120,U
	RTS
