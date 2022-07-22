	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_165
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	STD 79,U
	STD 39,U
	LDB #$d1
	STD -1,U
	LDB #$de
	STD -41,U
	LDB #$1e
	STD -81,U
	LDB #$1b
	STD -121,U
	LEAU -280,U

	LDB #$eb
	STD 79,U
	LDB #$e1
	STD -41,U
	LDB #$1b
	STD 119,U
	LDB #$11
	STD -121,U
	LDB #$be
	STD 39,U
	LDB #$b2
	STD -1,U
	LDB #$21
	STD -81,U
	LEAU -201,U

	LDB #$01
	STD ,U
	LDB #$11
	STD 40,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$dd11
	STD 79,U
	LDB #$1e
	STD 39,U
	LDB #$dd
	STD 119,U
	LDB #$ee
	STD -1,U
	LDB #$e4
	STD -41,U
	STD -81,U
	LDB #$eb
	STD -121,U
	LEAU -280,U

	STD 119,U
	LDD #$d1ee
	STD 79,U
	LDD #$de22
	STD 39,U
	LDD #$1411
	STD -41,U
	LDA #$1e
	STD -1,U
	LDA #$e4
	STD -81,U
	STD -121,U
	LEAU -201,U

	LDA #$ee
	STD 40,U
	STD ,U
	RTS

