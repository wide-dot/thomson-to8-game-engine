	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_250

	stb   <glb_alphaTiles
	LEAU 441,U

	LDD #$6676
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LEAU -281,U

	STA ,U
	STA -80,U
	STD 80,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$6767
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LEAU -281,U

	LDD 80,U
	LDA #$67
	ANDB #$F0
	ORB #$07
	STD 80,U
	STA ,U
	LDA -80,U
	ANDA #$F0
	ORA #$07
	STA -80,U
	RTS

