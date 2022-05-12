	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_226

	stb   <glb_alphaTiles
	LEAU 441,U

	LDD #$d78d
	STD 119,U
	LDA #$dd
	STD 39,U
	LDB #$dd
	STD -41,U
	LDB #$d4
	STD -121,U
	LEAU -321,U

	LDB #$44
	STD 120,U
	STD 40,U
	STB -120,U
	LDD -40,U
	LDA #$d4
	ANDB #$0F
	ORB #$40
	STD -40,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$7dd8
	STD 39,U
	LDD #$7878
	STD 119,U
	LDD #$dd44
	STD -41,U
	LDA #$33
	STD -121,U
	LEAU -321,U

	LDA #$34
	STA 40,U
	LDD #$d343
	STD 120,U
	LDA #$44
	STA -40,U
	STA -120,U
	RTS

