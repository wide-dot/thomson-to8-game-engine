	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_239

	stb   <glb_alphaTiles
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LDD #$8787
	STD 79,U
	LDA #$88
	STD -1,U
	STD -81,U
	LEAU -220,U

	STA 60,U
	LDA #$dd
	STA 20,U
	LDA #$78
	STA -20,U
	LDA -60,U
	ANDA #$F0
	ORA #$0d
	STA -60,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LDD #$8878
	STD -81,U
	LDA #$78
	STD 79,U
	STD -1,U
	LEAU -260,U

	LDA #$88
	STD 99,U
	LDD 59,U
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD 59,U
	LDA #$88
	STA 20,U
	LDA #$78
	STA -60,U
	STB -20,U
	LDA -100,U
	ANDA #$F0
	ORA #$0d
	STA -100,U
	RTS

