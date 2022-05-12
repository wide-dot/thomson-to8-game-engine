	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_267

	stb   <glb_alphaTiles
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LDD #$4d33
	STD 79,U
	LDD #$3ddd
	STD -81,U
	LDD #$3333
	STD -1,U
	LEAU -241,U

	LDD #$dddd
	STD 80,U
	STD 40,U
	STD ,U
	LDA #$d3
	STA -80,U
	LDD -40,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD -40,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$dd3d
	STD 79,U
	LDB #$33
	STD -1,U
	LDB #$dd
	STD 119,U
	STD 39,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -221,U

	STA -20,U
	STA -60,U
	STD 60,U
	STD 20,U
	RTS

