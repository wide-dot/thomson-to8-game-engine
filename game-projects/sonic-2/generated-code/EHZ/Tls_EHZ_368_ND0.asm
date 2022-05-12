	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_368

	stb   <glb_alphaTiles
	LEAU 281,U

	LDD #$3433
	STD 119,U
	STD 39,U
	STD -41,U
	LDD #$dddd
	STD -121,U
	LEAU -240,U

	STD -41,U
	LDD #$33d3
	STD 39,U

	LDU <glb_screen_location_1
	LEAU 281,U

	LDD #$4434
	STD 119,U
	STD 39,U
	STD -41,U
	LDD #$ddd3
	STD -121,U
	LEAU -240,U

	LDB #$3d
	STD 39,U
	LDB #$33
	STD -41,U
	RTS

