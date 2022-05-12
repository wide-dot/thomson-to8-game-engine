	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_380

	stb   <glb_alphaTiles
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LDD #$3344
	STD -81,U
	LDD #$dd43
	STD 79,U
	STD -1,U
	LEAU -280,U

	LDD #$4344
	STD 119,U
	STD 39,U
	STD -41,U
	LDD #$dddd
	STD 79,U
	STD -1,U
	STD -81,U
	LDD #$334d
	STD -121,U
	LEAU -180,U

	LDD 19,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD 19,U
	LDD -21,U
	LDA #$33
	ANDB #$0F
	ORB #$30
	STD -21,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$3433
	STD -81,U
	LDA #$dd
	STD 79,U
	STD -1,U
	LDB #$dd
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LEAU -281,U

	LDD #$4443
	STD 120,U
	LDB #$4d
	STD 40,U
	LDD #$dddd
	STD 80,U
	STD ,U
	LDA #$33
	STA -120,U
	STB -80,U
	LDD -40,U
	LDA #$34
	ANDB #$0F
	ORB #$d0
	STD -40,U
	LEAU -180,U

	LDA #$33
	STA -20,U
	LDA #$dd
	STA 20,U
	RTS

