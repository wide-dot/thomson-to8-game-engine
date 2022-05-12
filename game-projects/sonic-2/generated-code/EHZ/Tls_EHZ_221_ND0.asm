	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_221

	stb   <glb_alphaTiles
	LEAU 441,U

	LDD #$33dd
	STD 119,U
	STD 39,U
	LDD #$ddd4
	STD -41,U
	LDB #$44
	STD -121,U
	LEAU -321,U

	LDA #$d4
	STA -120,U
	LDD -40,U
	LDA #$dd
	ANDB #$0F
	ORB #$40
	STD -40,U
	LDD #$dd44
	STD 120,U
	STD 40,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$dd44
	STD 39,U
	STD -121,U
	LDB #$d4
	STD 119,U
	LDD #$3d44
	STD -41,U
	LEAU -321,U

	LDD 120,U
	LDA #$d4
	ANDB #$0F
	ORB #$40
	STD 120,U
	LDA #$34
	STA 40,U
	LDA #$44
	STA -40,U
	STA -120,U
	RTS

