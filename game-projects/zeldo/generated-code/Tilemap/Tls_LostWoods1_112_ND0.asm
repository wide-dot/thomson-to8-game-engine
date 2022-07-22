	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_112
	LEAU 481,U

	LDD #$44be
	STD 39,U
	LDD #$bbee
	STD 79,U
	LDA #$ee
	STD 119,U
	STD -81,U
	LDD #$444b
	STD -1,U
	STD -41,U
	LDD #$1bbe
	STD -121,U
	LEAU -280,U

	LDD #$1ee1
	STD 119,U
	LDD #$dddd
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$e4b4
	STD -1,U
	LDA #$eb
	STD 39,U
	LDB #$be
	STD -121,U
	LDD #$eeee
	STD 119,U
	LDB #$eb
	STD 79,U
	LDB #$ee
	STD -81,U
	LDD #$e444
	STD -41,U
	LEAU -280,U

	LDD #$1ee1
	STD 119,U
	LDD #$dddd
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U
	RTS

