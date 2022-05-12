	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_381

	stb   <glb_alphaTiles
	LEAU 480,U

	LDD #$3333
	STD 80,U
	LDD #$dddd
	STD 120,U
	LDD 40,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD 40,U
	LDD ,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD ,U
	LDA #$dd
	STA -40,U
	STA -120,U
	LDA #$3d
	STA -80,U
	LEAU -180,U

	LDA #$dd
	STA 20,U
	LDA -20,U
	ANDA #$0F
	ORA #$d0
	STA -20,U

	LDU <glb_screen_location_1
	LEAU 500,U

	LDA -100,U
	ANDA #$0F
	ORA #$d0
	STA -100,U
	LDA #$43
	STA 60,U
	LDA #$dd
	STA 100,U
	STA 20,U
	LDA #$d3
	STA -20,U
	LDA #$dd
	STA -60,U
	RTS

