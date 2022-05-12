	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_152
	LEAU 441,U

	LDD #$dd34
	STD 39,U
	LDB #$44
	STD 119,U
	LDB #$d3
	STD -41,U
	LDB #$dd
	STD -121,U
	LEAU -320,U

	LDA #$d7
	STD 119,U
	STD 39,U
	STD -41,U
	LDB #$d7
	STD -121,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$4333
	STD 119,U
	LDA #$3d
	STD 39,U
	LDD #$ddd3
	STD -121,U
	LDB #$33
	STD -41,U
	LEAU -320,U

	LDD #$7ddd
	STD 119,U
	LDD #$787d
	STD -41,U
	LDB #$78
	STD -121,U
	LDD #$7d7d
	STD 39,U
	RTS

