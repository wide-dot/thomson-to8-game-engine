	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_107
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -280,U

	LDB #$1e
	STD 79,U
	LDB #$dd
	STD 119,U
	LDB #$eb
	STD 39,U
	LDB #$e4
	STD -1,U
	LDB #$e5
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -201,U

	LDB #$0b
	STD 40,U
	LDB #$0e
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -280,U

	STD 119,U
	LDB #$5b
	STD -81,U
	STD -121,U
	LDB #$be
	STD 39,U
	LDB #$4b
	STD -1,U
	STD -41,U
	LDB #$ee
	STD 79,U
	LEAU -201,U

	LDB #$4b
	STD 40,U
	LDB #$bb
	STD ,U
	RTS

