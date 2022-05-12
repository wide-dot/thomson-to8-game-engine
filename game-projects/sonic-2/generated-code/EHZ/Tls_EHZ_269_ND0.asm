	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_269
	LEAU 441,U

	LDD #$ddd3
	STD 119,U
	LDD #$4444
	STD -41,U
	LDA #$3d
	STD 39,U
	LDA #$dd
	STD -121,U
	LEAU -320,U

	LDB #$33
	STD 119,U
	LDB #$44
	STD 39,U
	STD -41,U
	LDB #$4d
	STD -121,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$d444
	STD -41,U
	LDD #$dd3d
	STD 39,U
	STD -121,U
	LDB #$dd
	STD 119,U
	LEAU -320,U

	LDA #$d4
	STD -41,U
	LDB #$d3
	STD -121,U
	LDB #$4d
	STD 39,U
	LDD #$dddd
	STD 119,U
	RTS

