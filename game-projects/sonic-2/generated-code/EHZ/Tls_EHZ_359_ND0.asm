	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_359

	stb   <glb_alphaTiles
	LEAU 440,U

	LDD #$ddd3
	STD -40,U
	LDD 40,U
	LDA #$4d
	ANDB #$0F
	ORB #$d0
	STD 40,U
	LDA #$43
	STA 120,U
	LDD #$dd33
	STD -120,U
	LEAU -319,U

	LDD #$4344
	STD -41,U
	LDA #$44
	STD 119,U
	STD 39,U
	LDD #$3334
	STD -121,U

	LDU <glb_screen_location_1
	LEAU 440,U

	LDD -120,U
	LDA #$dd
	ANDB #$0F
	ORB #$30
	STD -120,U
	STA 120,U
	STA 40,U
	LDA #$d3
	STA -40,U
	LEAU -319,U

	LDD #$3433
	STD 119,U
	LDB #$44
	STD 39,U
	LDD #$3343
	STD -41,U
	LDB #$33
	STD -121,U
	RTS

