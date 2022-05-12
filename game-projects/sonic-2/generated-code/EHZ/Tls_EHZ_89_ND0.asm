	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_89

	stb   <glb_alphaTiles
	LEAU 440,U

	LDA #$dd
	STA 120,U
	STA 40,U
	STA -40,U
	LDD -120,U
	LDA #$dd
	ANDB #$0F
	ORB #$70
	STD -120,U
	LEAU -319,U

	LDD #$d388
	STD -41,U
	STD -121,U
	LDD #$dd87
	STD 39,U
	LDD 119,U
	LDA #$dd
	ANDB #$0F
	ORB #$80
	STD 119,U

	LDU <glb_screen_location_1
	LEAU 440,U

	LDA #$78
	STA 40,U
	STA -40,U
	STA -120,U
	LDA #$87
	STA 120,U
	LEAU -320,U

	LDD -120,U
	LDA #$d8
	ANDB #$0F
	ORB #$70
	STD -120,U
	LDA #$78
	STA 120,U
	STA 40,U
	STA -40,U
	RTS

