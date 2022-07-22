	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_65
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	STD 79,U
	STD 39,U
	LDB #$d2
	STD -81,U
	STD -121,U
	LDD #$d2dd
	STD -1,U
	LDB #$d2
	STD -41,U
	LEAU -280,U

	LDD #$dddd
	STD 119,U
	STD 79,U
	STD 39,U
	STD -121,U
	LDA #$d0
	STD -1,U
	LDA #$d9
	STD -41,U
	STD -81,U
	LEAU -201,U

	LDA #$dd
	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$222d
	STD -1,U
	LDA #$2d
	STD 39,U
	LDD #$dddd
	STD 119,U
	STD 79,U
	LDD #$d222
	STD -41,U
	LDB #$dd
	STD -81,U
	LDA #$2d
	STD -121,U
	LEAU -280,U

	LDA #$dd
	STD 119,U
	LDA #$9d
	STD -121,U
	LDA #$90
	STD -1,U
	LDA #$29
	STD -41,U
	STD -81,U
	LDA #$0d
	STD 79,U
	STD 39,U
	LEAU -201,U

	LDA #$9d
	STD 40,U
	LDA #$dd
	STD ,U
	RTS

