	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_253

	stb   <glb_alphaTiles
	LEAU 441,U

	LDD #$43dd
	STD 119,U
	LDD -41,U
	ANDA #$F0
	ORA #$03
	LDB #$d4
	STD -41,U
	LDD #$33dd
	STD 39,U
	LDA #$d4
	STA -120,U
	LEAU -240,U

	STA 40,U
	LDA -40,U
	ANDA #$F0
	ORA #$03
	STA -40,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$dddd
	STD 119,U
	LDB #$44
	STD 39,U
	STD -41,U
	STD -121,U
	LEAU -280,U

	LDA #$43
	STA 80,U
	STA ,U
	LDA -80,U
	ANDA #$F0
	ORA #$03
	STA -80,U
	RTS

