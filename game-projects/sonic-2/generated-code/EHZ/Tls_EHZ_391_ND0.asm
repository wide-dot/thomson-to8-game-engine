	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_391

	stb   <glb_alphaTiles
	LEAU 481,U

	LDA #$dd
	STA 120,U
	STA 40,U
	LDA #$77
	STA 80,U
	STA ,U
	LDD #$dddd
	STD -41,U
	STD -121,U
	LDB #$77
	STD -81,U
	LEAU -280,U

	STD 119,U
	STD 39,U
	STD -41,U
	LDB #$dd
	STD 79,U
	STD -1,U
	STD -81,U
	LDD #$3378
	STD -121,U
	LEAU -180,U

	LDD #$dddd
	STD 19,U
	LDD #$4478
	STD -21,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$dddd
	STD -41,U
	STD -121,U
	LDA #$78
	STA 80,U
	STA ,U
	STB 120,U
	STB 40,U
	LDD #$dd78
	STD -81,U
	LEAU -280,U

	STD 119,U
	LDB #$88
	STD 39,U
	STD -41,U
	STD -121,U
	LDB #$dd
	STD 79,U
	STD -1,U
	STD -81,U
	LEAU -180,U

	STD 19,U
	LDD -21,U
	LDA #$dd
	ANDB #$0F
	ORB #$70
	STD -21,U
	RTS

