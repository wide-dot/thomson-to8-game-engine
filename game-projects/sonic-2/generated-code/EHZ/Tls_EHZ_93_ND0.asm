	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_93

	stb   <glb_alphaTiles
	LEAU 441,U

	LDD #$8787
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LEAU -241,U

	LDD 40,U
	LDA #$87
	ANDB #$F0
	ORB #$07
	STD 40,U
	STA -40,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$7878
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LEAU -241,U

	LDA -40,U
	ANDA #$F0
	ORA #$08
	STA -40,U
	LDD 40,U
	LDA #$78
	ANDB #$F0
	ORB #$08
	STD 40,U
	RTS

