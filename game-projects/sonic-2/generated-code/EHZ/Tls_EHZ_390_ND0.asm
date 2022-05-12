	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_390

	stb   <glb_alphaTiles
	LEAU 321,U

	LDD #$dddd
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -240,U

	STD 39,U
	STD -41,U
	LDD #$33d3
	STD 79,U
	LDD #$4433
	STD -1,U
	LDB #$dd
	STD -81,U

	LDU <glb_screen_location_1
	LEAU 321,U

	LDD #$dddd
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -240,U

	LDB #$33
	STD 79,U
	STD -81,U
	LDB #$dd
	STD 39,U
	STD -41,U
	LDD #$4333
	STD -1,U
	RTS

