	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_70

	stb   <glb_alphaTiles
	LEAU 441,U

	LDD #$8787
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LEAU -321,U

	STD 120,U
	LDD 40,U
	LDA #$87
	ANDB #$0F
	ORB #$80
	STD 40,U
	LDD -40,U
	LDA #$87
	ANDB #$0F
	ORB #$80
	STD -40,U
	STA -120,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$7878
	STD 119,U
	STD 39,U
	STD -41,U
	LDD -121,U
	LDA #$78
	ANDB #$0F
	ORB #$70
	STD -121,U
	LEAU -321,U

	STA -120,U
	LDD 120,U
	LDA #$78
	ANDB #$0F
	ORB #$70
	STD 120,U
	LDD 40,U
	LDA #$78
	ANDB #$F0
	ORB #$07
	STD 40,U
	LDD -40,U
	LDA #$78
	ANDB #$0F
	ORB #$70
	STD -40,U
	RTS
