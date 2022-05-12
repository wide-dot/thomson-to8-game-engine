	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_94

	stb   <glb_alphaTiles
	LEAU 480,U

	LDD 80,U
	LDA #$87
	ANDB #$0F
	ORB #$80
	STD 80,U
	STA ,U
	STA -80,U

	LDU <glb_screen_location_1
	LEAU 480,U

	LDD #$7878
	STD 80,U
	LDD ,U
	LDA #$78
	ANDB #$0F
	ORB #$70
	STD ,U
	LDA -80,U
	ANDA #$F0
	ORA #$08
	STA -80,U
	RTS

