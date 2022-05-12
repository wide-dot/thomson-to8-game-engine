	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_237

	stb   <glb_alphaTiles
	LEAU 560,U

	LDD #$dddd
	STD 40,U
	LDD ,U
	LDA #$87
	ANDB #$F0
	ORB #$07
	STD ,U
	LDA -40,U
	ANDA #$0F
	ORA #$d0
	STA -40,U

	LDU <glb_screen_location_1
	LEAU 581,U

	LDD #$dddd
	STD 19,U
	LDD -21,U
	ANDA #$0F
	ORA #$70
	LDB #$78
	STD -21,U
	RTS

