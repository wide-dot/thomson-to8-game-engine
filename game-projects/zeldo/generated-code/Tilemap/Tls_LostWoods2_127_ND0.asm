	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_127
	LEAU 481,U

	LDD #$dd22
	STD 119,U
	LDB #$2e
	STD 79,U
	LDB #$eb
	STD 39,U
	STD -1,U
	LDB #$e4
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -280,U

	LDB #$ee
	STD 119,U
	LDB #$e4
	STD 79,U
	LDB #$eb
	STD 39,U
	STD -1,U
	LDB #$e4
	STD -41,U
	STD -81,U
	LDB #$eb
	STD -121,U
	LEAU -201,U

	LDB #$db
	STD 40,U
	LDB #$de
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$dd22
	STD 119,U
	LDB #$ee
	STD 79,U
	LDB #$be
	STD 39,U
	LDB #$bb
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -280,U

	LDB #$eb
	STD 119,U
	LDB #$b4
	STD 39,U
	LDB #$bb
	STD -41,U
	STD -81,U
	LDB #$4e
	STD 79,U
	LDB #$4b
	STD -1,U
	STD -121,U
	LEAU -201,U

	LDB #$ed
	STD ,U
	LDB #$be
	STD 40,U
	RTS

