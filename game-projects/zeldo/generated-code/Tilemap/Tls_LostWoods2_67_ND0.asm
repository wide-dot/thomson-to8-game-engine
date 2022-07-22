	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_67
	LEAU 481,U

	LDD #$eee2
	STD -81,U
	LDB #$ee
	STD -121,U
	LDB #$2d
	STD 79,U
	LDB #$22
	STD 39,U
	STD -1,U
	STD -41,U
	LDD #$22dd
	STD 119,U
	LEAU -280,U

	LDD #$4bee
	STD -81,U
	STD -121,U
	LDA #$bb
	STD -1,U
	STD -41,U
	LDA #$be
	STD 119,U
	STD 79,U
	STD 39,U
	LEAU -201,U

	LDA #$4b
	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$e222
	STD 39,U
	STD -1,U
	LDD #$22dd
	STD 119,U
	STD 79,U
	LDD #$ee22
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -280,U

	LDB #$ee
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U
	RTS

