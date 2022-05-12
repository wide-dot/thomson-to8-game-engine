	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_32
	LEAU 441,U

	LDD #$dd3d
	STD 119,U
	LDD #$d7dd
	STD -121,U
	LDA #$dd
	STD 39,U
	STD -41,U
	LEAU -320,U

	LDD #$8787
	STD -41,U
	STD -121,U
	LDB #$d7
	STD 39,U
	LDA #$d7
	STD 119,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$7ddd
	STD -41,U
	STD -121,U
	LDD #$ddd3
	STD 119,U
	LDB #$dd
	STD 39,U
	LEAU -320,U

	LDD #$7d7d
	STD 119,U
	LDD #$7878
	STD 39,U
	STD -41,U
	STD -121,U
	RTS

