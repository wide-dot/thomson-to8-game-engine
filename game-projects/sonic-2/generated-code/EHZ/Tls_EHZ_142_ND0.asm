	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_142
	LEAU 441,U

	LDD #$4444
	STD -41,U
	LDD #$3333
	STD 119,U
	STD 39,U
	LDD #$5555
	STD -121,U
	LEAU -320,U

	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$3333
	STD 119,U
	LDB #$34
	STD 39,U
	LDD #$5544
	STD -121,U
	LDA #$44
	STD -41,U
	LEAU -320,U

	LDA #$55
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	RTS
