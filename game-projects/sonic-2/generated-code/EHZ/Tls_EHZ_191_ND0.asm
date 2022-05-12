	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_191
	LEAU 441,U

	LDD #$dd54
	STD -41,U
	LDD #$d355
	STD 39,U
	LDA #$33
	STD 119,U
	LDD #$dd44
	STD -121,U
	LEAU -320,U

	LDB #$34
	STD 119,U
	LDB #$d4
	STD 39,U
	LDD #$d7d3
	STD -41,U
	LDB #$dd
	STD -121,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$5444
	STD 119,U
	LDA #$44
	STD 39,U
	LDA #$43
	STD -41,U
	LDD #$3d34
	STD -121,U
	LEAU -320,U

	LDD #$ddd3
	STD 119,U
	LDB #$dd
	STD 39,U
	STD -41,U
	LDA #$d8
	STD -121,U
	RTS

