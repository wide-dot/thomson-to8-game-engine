	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_249
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LDD #$4455
	STD 79,U
	STD -1,U
	STD -81,U
	LEAU -280,U

	LDD #$dddd
	STD 79,U
	STD -1,U
	STD -81,U
	LDD #$4455
	STD 119,U
	STD 39,U
	LDA #$43
	STD -41,U
	LDA #$33
	STD -121,U
	LEAU -180,U

	LDB #$44
	STD -21,U
	LDD #$dddd
	STD 19,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LDD #$5544
	STD 79,U
	STD -1,U
	STD -81,U
	LEAU -280,U

	LDD #$dddd
	STD 79,U
	STD -1,U
	STD -81,U
	LDD #$5544
	STD 119,U
	STD 39,U
	STD -41,U
	LDA #$54
	STD -121,U
	LEAU -180,U

	LDD #$dddd
	STD 19,U
	LDD #$4444
	STD -21,U
	RTS
