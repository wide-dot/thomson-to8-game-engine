	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_68
	LEAU 441,U

	LDD #$dddd
	STD -41,U
	STD -121,U
	LDD #$d33d
	STD 39,U
	LDD #$334d
	STD 119,U
	LEAU -320,U

	LDD #$dd87
	STD -121,U
	LDB #$d7
	STD 119,U
	STD 39,U
	STD -41,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$4433
	STD 119,U
	LDD #$34dd
	STD -41,U
	LDA #$44
	STD 39,U
	LDA #$d3
	STD -121,U
	LEAU -320,U

	LDD #$78d8
	STD -41,U
	LDD #$dddd
	STD 119,U
	LDB #$d8
	STD 39,U
	LDD #$7878
	STD -121,U
	RTS

