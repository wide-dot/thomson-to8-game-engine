	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_119
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
	LDA #$82
	STD -41,U
	LDA #$28
	STD 39,U
	LDB #$de
	STD -81,U
	LDD #$88dd
	STD -1,U
	LDA #$d2
	STD 79,U
	LDD #$88e3
	STD -121,U
	LEAU -201,U

	LDA #$22
	STD 40,U
	LDA #$dd
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

	LDA #$82
	STD 39,U
	STD -1,U
	STD -41,U
	LDA #$2d
	STD 79,U
	LDA #$dd
	STD 119,U
	LDD #$82ee
	STD -81,U
	LDD #$8d33
	STD -121,U
	LEAU -201,U

	LDA #$dd
	STD ,U
	LDA #$2d
	STD 40,U
	RTS

