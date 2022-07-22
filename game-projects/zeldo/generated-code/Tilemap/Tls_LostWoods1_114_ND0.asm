	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_114
	LEAU 481,U

	LDD #$dd21
	STD 39,U
	STD -1,U
	STD -41,U
	LDB #$11
	STD 119,U
	STD 79,U
	LDB #$e1
	STD -81,U
	LDB #$e2
	STD -121,U
	LEAU -280,U

	LDB #$d1
	STD -1,U
	STD -41,U
	LDB #$dd
	STD -81,U
	STD -121,U
	LDB #$1e
	STD 79,U
	STD 39,U
	LDB #$ee
	STD 119,U
	LEAU -201,U

	LDB #$dd
	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$1e22
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	LDD #$de21
	STD -41,U
	LDB #$11
	STD -81,U
	LDA #$d1
	STD -121,U
	LEAU -280,U

	LDD #$dd21
	STD 119,U
	LDB #$e2
	STD 79,U
	LDB #$ee
	STD 39,U
	STD -1,U
	LDB #$11
	STD -41,U
	STD -81,U
	LDB #$dd
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U
	RTS

