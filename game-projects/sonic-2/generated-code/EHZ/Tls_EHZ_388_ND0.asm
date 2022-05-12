	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_388

	stb   <glb_alphaTiles
	LEAU 101,U

	LDA 100,U
	ANDA #$F0
	ORA #$0d
	STA 100,U
	LDA #$33
	STA 60,U
	STA -20,U
	LDD -61,U
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD -61,U
	STB 20,U
	LDD #$dd43
	STD -101,U

	LDU <glb_screen_location_1
	LEAU 161,U

	LDA 120,U
	ANDA #$F0
	ORA #$0d
	STA 120,U
	LDA #$3d
	STA 80,U
	LDA #$dd
	STA 40,U
	STA ,U
	LDD #$dddd
	STD -121,U
	LDD #$3333
	STD -81,U
	LDD -41,U
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD -41,U
	LEAU -160,U

	LDD #$d3dd
	STD -1,U
	RTS

