	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_83
	LEAU 481,U

	LDD #$dd11
	STD 119,U
	LDD #$d121
	STD -1,U
	LDA #$dd
	STD 79,U
	STD 39,U
	LDA #$de
	STD -41,U
	STD -81,U
	LDD #$1e11
	STD -121,U
	LEAU -280,U

	STD 119,U
	STD 79,U
	LDA #$14
	STD 39,U
	LDB #$12
	STD -1,U
	LDD #$1e22
	STD -81,U
	LDA #$1b
	STD -41,U
	LDA #$de
	STD -121,U
	LEAU -201,U

	LDD #$dd11
	STD ,U
	LDD #$d112
	STD 40,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$eb22
	STD 39,U
	LDA #$ee
	STD 119,U
	STD 79,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -280,U

	STD 119,U
	LDA #$e2
	STD 79,U
	LDA #$21
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LDA #$e1
	STD 39,U
	LEAU -201,U

	STD 40,U
	LDA #$e2
	STD ,U
	RTS

