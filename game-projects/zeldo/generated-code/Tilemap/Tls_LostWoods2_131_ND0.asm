	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_131
	LEAU 481,U

	LDD #$d2dd
	STD -41,U
	STD -81,U
	STD -121,U
	LDA #$dd
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	LEAU -280,U

	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	LDB #$d2
	STD -121,U
	LDD #$d2dd
	STD -41,U
	LDB #$d2
	STD -81,U
	LEAU -201,U

	LDA #$dd
	STD 40,U
	LDB #$dd
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	STD 79,U
	STD -81,U
	STD -121,U
	LDA #$2d
	STD 39,U
	STD -1,U
	LDA #$22
	STD -41,U
	LEAU -280,U

	LDA #$dd
	STD 119,U
	STD 79,U
	STD 39,U
	LDD #$222d
	STD -41,U
	LDA #$2d
	STD -1,U
	LDD #$d222
	STD -81,U
	LDB #$dd
	STD -121,U
	LEAU -201,U

	LDA #$2d
	STD 40,U
	LDA #$dd
	STD ,U
	RTS

