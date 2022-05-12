	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_238

	stb   <glb_alphaTiles
	LEAU 521,U

	LDD #$dddd
	STD 79,U
	LDD #$8887
	STD 39,U
	LDA -80,U
	ANDA #$F0
	ORA #$0d
	STA -80,U
	LDA #$88
	STA -40,U
	LDD -1,U
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD -1,U

	LDU <glb_screen_location_1
	LEAU 501,U

	LDD #$dddd
	STD 99,U
	STD 19,U
	LDD #$8878
	STD 59,U
	LDD -21,U
	ANDA #$F0
	ORA #$07
	LDB #$88
	STD -21,U
	LDA #$dd
	STA -60,U
	LDA -100,U
	ANDA #$F0
	ORA #$07
	STA -100,U
	RTS

