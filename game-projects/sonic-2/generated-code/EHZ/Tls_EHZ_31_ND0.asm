	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_31
	LEAU 441,U

	LDD #$d334
	STD 119,U
	LDD #$dddd
	STD -41,U
	STD -121,U
	LDD #$d3d3
	STD 39,U
	LEAU -320,U

	LDD #$d7dd
	STD 119,U
	STD 39,U
	LDD #$878d
	STD -41,U
	LDB #$87
	STD -121,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$33d3
	STD 119,U
	LDD #$dddd
	STD -41,U
	STD -121,U
	LDA #$d3
	STD 39,U
	LEAU -320,U

	LDD #$d878
	STD 39,U
	LDD #$dddd
	STD 119,U
	LDD #$7878
	STD -41,U
	STD -121,U
	RTS

