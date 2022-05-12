	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_208

	stb   <glb_alphaTiles
	LEAU 521,U

	LDA #$88
	STA -40,U
	LDD #$8887
	STD 39,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD -1,U
	ANDA #$F0
	ORA #$07
	LDB #$88
	STD -1,U
	LDD #$8878
	STD 79,U
	LDA -80,U
	ANDA #$F0
	ORA #$07
	STA -80,U
	RTS

