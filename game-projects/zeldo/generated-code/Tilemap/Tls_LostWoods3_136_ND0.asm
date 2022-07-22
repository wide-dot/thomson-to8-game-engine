	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods3_136
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

	LDD #$dddd
	STD 119,U
	STD 79,U
	LDB #$d1
	STD 39,U
	STD -1,U
	LDB #$d0
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -280,U

	LDB #$de
	STD 119,U
	LDB #$d6
	STD -121,U
	LDB #$46
	STD -1,U
	STD -41,U
	LDB #$e4
	STD 39,U
	LDB #$e6
	STD -81,U
	LDB #$0e
	STD 79,U
	LEAU -201,U

	LDB #$de
	STD 40,U
	LDB #$d0
	STD ,U
	RTS

