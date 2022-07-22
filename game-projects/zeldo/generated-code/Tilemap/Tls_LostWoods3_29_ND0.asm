	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods3_29
	LEAU 481,U

	LDD #$d222
	STD 119,U
	STD 79,U
	STD 39,U
	LDA #$dd
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -280,U

	LDB #$d2
	STD 79,U
	STD 39,U
	STD -1,U
	LDB #$dd
	STD -41,U
	STD -81,U
	STD -121,U
	LDB #$22
	STD 119,U
	LEAU -201,U

	LDB #$dd
	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$dd22
	STD -121,U
	LDA #$d2
	STD -81,U
	LDA #$22
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	LEAU -280,U

	LDD #$ddd2
	STD -121,U
	LDB #$22
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	LEAU -201,U

	LDB #$dd
	STD 40,U
	STD ,U
	RTS

