	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_389

	stb   <glb_alphaTiles
	LEAU 281,U

	LDA #$dd
	STA 120,U
	STA 80,U
	LDD #$dddd
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LDD 39,U
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD 39,U
	LEAU -220,U

	LDD #$dddd
	STD 59,U
	STD -21,U
	STD -61,U
	LDD #$333d
	STD 19,U

	LDU <glb_screen_location_1
	LEAU 321,U

	LDA #$dd
	STA 80,U
	LDA 120,U
	ANDA #$F0
	ORA #$0d
	STA 120,U
	LDD #$dddd
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -240,U

	LDD #$3333
	STD -1,U
	LDD #$dddd
	STD 39,U
	STD -41,U
	LDD #$33d3
	STD 79,U
	LDB #$dd
	STD -81,U
	RTS

