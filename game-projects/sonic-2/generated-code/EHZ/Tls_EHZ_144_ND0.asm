	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_144

	stb   <glb_alphaTiles
	LEAU 441,U

	LDD #$8787
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LEAU -281,U

	STD 80,U
	STD ,U
	STA -80,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$7878
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LEAU -281,U

	STD 80,U
	LDA -80,U
	ANDA #$F0
	ORA #$08
	STA -80,U
	LDD ,U
	LDA #$78
	ANDB #$F0
	ORB #$08
	STD ,U
	RTS

