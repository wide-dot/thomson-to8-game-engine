	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_217

	stb   <glb_alphaTiles
	LEAU 441,U

	LDD #$3344
	STD 119,U
	STD 39,U
	LDD #$dd43
	STD -41,U
	LDD -121,U
	LDA #$dd
	ANDB #$0F
	ORB #$40
	STD -121,U
	LEAU -321,U

	LDD 120,U
	LDA #$dd
	ANDB #$0F
	ORB #$30
	STD 120,U
	STA 40,U
	LDA #$d3
	STA -40,U
	LDA #$d4
	STA -120,U

	LDU <glb_screen_location_1
	LEAU 440,U

	LDA #$34
	STA -120,U
	LDA #$d3
	STA 40,U
	LDA #$d4
	STA -40,U
	LDD 120,U
	LDA #$dd
	ANDB #$0F
	ORB #$30
	STD 120,U
	LEAU -320,U

	LDA #$44
	STA 120,U
	STA 40,U
	STA -40,U
	LDA #$43
	STA -120,U
	RTS

