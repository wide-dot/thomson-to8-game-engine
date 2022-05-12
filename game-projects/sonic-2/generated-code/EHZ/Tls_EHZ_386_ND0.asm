	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_386

	stb   <glb_alphaTiles
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LDA #$4d
	STD 79,U
	LDA #$44
	STD -81,U
	LDB #$3d
	STD -1,U
	LEAU -281,U

	LDB #$dd
	STD 120,U
	LDA -120,U
	ANDA #$0F
	ORA #$d0
	STA -120,U
	LDA #$d3
	STA 40,U
	STB ,U
	STA -40,U
	STB -80,U
	LDD 80,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD 80,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	STD 39,U
	STD -41,U
	LDB #$33
	STD 79,U
	LDD -121,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD -121,U
	LDD #$43d3
	STD -81,U
	LDA #$3d
	STD -1,U
	LEAU -241,U

	LDA #$dd
	STA 40,U
	LDA #$33
	STA 80,U
	STA ,U
	LDA -40,U
	ANDA #$0F
	ORA #$d0
	STA -40,U
	LDA -80,U
	ANDA #$0F
	ORA #$30
	STA -80,U
	RTS

