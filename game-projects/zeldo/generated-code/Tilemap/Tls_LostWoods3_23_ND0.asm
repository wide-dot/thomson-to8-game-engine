	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods3_23
	LEAU 481,U

	LDD #$d2d9
	STD -1,U
	STD -41,U
	LDD #$dddd
	STD 119,U
	STD 79,U
	LDB #$d0
	STD 39,U
	LDB #$dd
	STD -81,U
	STD -121,U
	LEAU -280,U

	LDA #$d0
	STD -1,U
	LDA #$dd
	STD 119,U
	STD 79,U
	STD 39,U
	LDB #$d2
	STD -121,U
	LDD #$d9dd
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

	LDD #$2d90
	STD 39,U
	LDB #$9d
	STD -121,U
	LDD #$dd0d
	STD 119,U
	STD 79,U
	LDD #$2229
	STD -1,U
	LDA #$d2
	STD -41,U
	LDB #$9d
	STD -81,U
	LEAU -280,U

	LDD #$dddd
	STD 119,U
	LDD #$902d
	STD -1,U
	LDD #$0ddd
	STD 79,U
	STD 39,U
	LDD #$292d
	STD -41,U
	LDB #$22
	STD -81,U
	LDD #$9ddd
	STD -121,U
	LEAU -201,U

	LDA #$dd
	STD ,U
	LDA #$9d
	STD 40,U
	RTS

