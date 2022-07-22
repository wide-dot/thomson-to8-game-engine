	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_156
	LEAU 481,U

	LDD #$dd01
	STD 119,U
	STD 79,U
	LDB #$00
	STD 39,U
	LDB #$e0
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -280,U

	LDB #$ee
	STD 119,U
	LDB #$de
	STD 79,U
	STD 39,U
	LDB #$dd
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$dd01
	STD -81,U
	STD -121,U
	LDD #$ee11
	STD 39,U
	LDA #$de
	STD -1,U
	STD -41,U
	LDA #$e0
	STD 119,U
	STD 79,U
	LEAU -280,U

	LDD #$dd00
	STD 119,U
	STD 79,U
	LDB #$de
	STD -41,U
	LDB #$dd
	STD -81,U
	STD -121,U
	LDB #$e0
	STD 39,U
	LDB #$ee
	STD -1,U
	LEAU -201,U

	LDB #$dd
	STD 40,U
	STD ,U
	RTS

