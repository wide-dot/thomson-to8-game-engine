	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_38
	LEAU 441,U

	LDD #$4433
	STD 39,U
	LDA #$43
	STD 119,U
	LDD #$4444
	STD -41,U
	LDB #$55
	STD -121,U
	LEAU -320,U

	LDD #$d345
	STD 39,U
	LDB #$44
	STD -41,U
	LDB #$55
	STD 119,U
	LDD #$dd34
	STD -121,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$5544
	STD -121,U
	LDA #$44
	STD -41,U
	LDD #$3333
	STD 119,U
	LDB #$34
	STD 39,U
	LEAU -320,U

	LDD #$5454
	STD 119,U
	LDB #$44
	STD 39,U
	LDD #$44d4
	STD -41,U
	LDD #$33d3
	STD -121,U
	RTS
