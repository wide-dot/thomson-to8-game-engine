	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_274

	stb   <glb_alphaTiles
	LEAU 281,U

	LDA #$33
	STA 40,U
	STA -40,U
	LDA #$dd
	STA 80,U
	STA ,U
	LDA 120,U
	ANDA #$F0
	ORA #$03
	STA 120,U
	LDD #$dddd
	STD -81,U
	LDD #$4dd4
	STD -121,U
	LEAU -220,U

	LDD #$dddd
	STD 59,U
	STD -21,U
	LDA #$43
	STD -61,U
	LDA #$4d
	STD 19,U

	LDU <glb_screen_location_1
	LEAU 361,U

	LDA 120,U
	ANDA #$F0
	ORA #$0d
	STA 120,U
	LDA #$dd
	STA 80,U
	STA ,U
	LDD #$dd44
	STD -121,U
	LDD -81,U
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD -81,U
	LDA #$3d
	STA 40,U
	LDA #$34
	STA -40,U
	LEAU -260,U

	LDA #$dd
	STD 99,U
	STD 19,U
	STD -61,U
	STD -101,U
	LDB #$34
	STD -21,U
	LDB #$44
	STD 59,U
	RTS

