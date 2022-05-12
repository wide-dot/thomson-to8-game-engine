	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_71

	stb   <glb_alphaTiles
	LEAU 480,U

	LDD #$8787
	STD 80,U
	STA -80,U
	LDD ,U
	LDA #$87
	ANDB #$F0
	ORB #$07
	STD ,U

	LDU <glb_screen_location_1
	LEAU 480,U

	LDD 80,U
	LDA #$78
	ANDB #$F0
	ORB #$08
	STD 80,U
	STA ,U
	LDA -80,U
	ANDA #$F0
	ORA #$08
	STA -80,U
	RTS

