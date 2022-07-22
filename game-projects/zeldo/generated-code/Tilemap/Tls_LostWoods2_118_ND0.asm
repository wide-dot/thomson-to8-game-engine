	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_118
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

	LDD #$ded8
	STD -81,U
	LDD #$dddd
	STD 119,U
	LDB #$d2
	STD 79,U
	STD 39,U
	LDB #$d8
	STD -1,U
	STD -41,U
	LDD #$e3d2
	STD -121,U
	LEAU -201,U

	STD 40,U
	LDB #$dd
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
	LDB #$d2
	STD 79,U
	LDD #$ee28
	STD -81,U
	LDD #$dd88
	STD -1,U
	LDB #$28
	STD 39,U
	STD -41,U
	LDD #$3388
	STD -121,U
	LEAU -201,U

	LDB #$22
	STD 40,U
	LDB #$dd
	STD ,U
	RTS

