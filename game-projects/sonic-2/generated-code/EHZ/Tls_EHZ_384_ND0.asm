	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_384
	LEAU 481,U

	LDD #$dd4d
	STD 79,U
	LDB #$dd
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LDD #$3d44
	STD -1,U
	STD -81,U
	LEAU -280,U

	LDD #$dd43
	STD 119,U
	LDB #$44
	STD -41,U
	LDA #$4d
	STD -121,U
	LDD #$dd3d
	STD 39,U
	LDB #$dd
	STD 79,U
	STD -1,U
	STD -81,U
	LEAU -180,U

	STD 19,U
	LDB #$44
	STD -21,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$444d
	STD -81,U
	LDD #$343d
	STD -1,U
	LDD #$dddd
	STD 119,U
	STD 79,U
	STD 39,U
	STD -41,U
	STD -121,U
	LEAU -280,U

	LDA #$d3
	STD 119,U
	LDD #$444d
	STD -121,U
	LDD #$34dd
	STD -41,U
	LDA #$dd
	STD 79,U
	STD 39,U
	STD -1,U
	STD -81,U
	LEAU -180,U

	LDD #$d433
	STD -21,U
	LDD #$dddd
	STD 19,U
	RTS

