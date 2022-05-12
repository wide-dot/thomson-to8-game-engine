	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_378

	stb   <glb_alphaTiles
	LEAU 481,U

	LDA #$33
	STA 80,U
	STA ,U
	STA -80,U
	LDA 120,U
	ANDA #$F0
	ORA #$0d
	STA 120,U
	LDA #$dd
	STA 40,U
	STA -40,U
	STA -120,U
	LEAU -280,U

	LDD 119,U
	ANDA #$F0
	ORA #$04
	LDB #$33
	STD 119,U
	LDD 79,U
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD 79,U
	LDD #$4443
	STD 39,U
	LDD #$dddd
	STD -1,U
	STD -81,U
	LDD #$3433
	STD -121,U
	LDA #$44
	STD -41,U
	LEAU -180,U

	LDA #$33
	STD -21,U
	LDD #$dddd
	STD 19,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$4334
	STD -81,U
	STB 80,U
	LDD -1,U
	ANDA #$F0
	ORA #$03
	LDB #$33
	STD -1,U
	LDD -41,U
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD -41,U
	STB 120,U
	STB 40,U
	LDD #$dddd
	STD -121,U
	LEAU -280,U

	LDD #$4444
	STD 119,U
	STD 39,U
	LDD #$4333
	STD -121,U
	LDD #$4434
	STD -41,U
	LDD #$dddd
	STD 79,U
	STD -1,U
	STD -81,U
	LEAU -180,U

	LDD #$3333
	STD -21,U
	LDD #$dddd
	STD 19,U
	RTS

