	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_268

	stb   <glb_alphaTiles
	LEAU 480,U

	LDD #$dddd
	STD 120,U
	STD 40,U
	LDB #$43
	STD 80,U
	LDD ,U
	LDA #$dd
	ANDB #$0F
	ORB #$30
	STD ,U
	STA -40,U
	STA -80,U
	STA -120,U
	LEAU -160,U

	LDA ,U
	ANDA #$0F
	ORA #$d0
	STA ,U

	LDU <glb_screen_location_1
	LEAU 500,U

	LDD 60,U
	LDA #$44
	ANDB #$0F
	ORB #$d0
	STD 60,U
	LDD #$dddd
	STD 100,U
	STA 20,U
	STA -60,U
	STA -100,U
	LDA #$33
	STA -20,U
	RTS

