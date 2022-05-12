	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_283

	stb   <glb_alphaTiles
	LEAU 481,U

	LDD #$34dd
	STD -1,U
	LDD #$444d
	STD 79,U
	LDD #$dddd
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LDA #$d3
	STD -81,U
	LEAU -281,U

	STD 120,U
	LDA #$dd
	STD 80,U
	LDA #$33
	STD 40,U
	STA -40,U
	LDD ,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD ,U
	STA -80,U
	LDA #$d3
	STA -120,U
	LEAU -180,U

	LDA #$dd
	STA 20,U
	LDA -20,U
	ANDA #$0F
	ORA #$d0
	STA -20,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$4dd3
	STD -81,U
	LDD #$4444
	STD 79,U
	STD -1,U
	LDD #$dddd
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LEAU -281,U

	LDA -120,U
	ANDA #$0F
	ORA #$30
	STA -120,U
	STB 80,U
	STB ,U
	STB -80,U
	LDA #$33
	STA 40,U
	STA -40,U
	LDD 120,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD 120,U
	RTS

