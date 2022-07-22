	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods3_134
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	LDB #$de
	STD -121,U
	LEAU -280,U

	LDB #$ee
	STD -81,U
	LDB #$e0
	STD -121,U
	LDB #$de
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	LEAU -201,U

	LDB #$e0
	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$ddde
	STD 119,U
	STD 79,U
	LDB #$ee
	STD 39,U
	STD -1,U
	LDB #$e0
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -280,U

	LDB #$00
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
	RTS

