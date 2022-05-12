	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_62

	stb   <glb_alphaTiles
	LEAU 121,U

	LDD #$4333
	STD 119,U
	LDA #$44
	STD 39,U
	LDB #$55
	STD -121,U
	LDB #$44
	STD -41,U

	LDU <glb_screen_location_1
	LEAU 121,U

	LDD #$3333
	STD 119,U
	LDB #$34
	STD 39,U
	LDD #$4444
	STD -41,U
	LDA #$55
	STD -121,U
	RTS

