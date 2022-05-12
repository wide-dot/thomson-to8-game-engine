	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_383

	stb   <glb_alphaTiles
	LEAU 361,U

	LDA 120,U
	ANDA #$F0
	ORA #$03
	STA 120,U
	LDA #$dd
	STA 80,U
	STA ,U
	LDA #$d3
	STA -40,U
	LDA #$33
	STA 40,U
	LDD -81,U
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD -81,U
	LDD -121,U
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD -121,U
	LEAU -260,U

	LDD #$dddd
	STD 99,U
	STD 19,U
	STD -61,U
	LDD #$4444
	STD -21,U
	STD -101,U
	LDD #$43d4
	STD 59,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDA 120,U
	ANDA #$F0
	ORA #$0d
	STA 120,U
	LDA 80,U
	ANDA #$F0
	ORA #$0d
	STA 80,U
	LDA #$dd
	STA 40,U
	STA -40,U
	LDA #$33
	STA ,U
	STA -80,U
	LDD -121,U
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD -121,U
	LEAU -280,U

	LDD #$dd33
	STD 119,U
	LDB #$3d
	STD 39,U
	LDB #$dd
	STD 79,U
	STD -1,U
	STD -81,U
	LDD #$4d44
	STD -121,U
	LDD #$dd43
	STD -41,U
	LEAU -180,U

	LDB #$dd
	STD 19,U
	LDB #$44
	STD -21,U
	RTS

