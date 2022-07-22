	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_120
	LEAU 481,U

	LDD #$22ee
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LDD #$2eeb
	STD 39,U
	LDB #$be
	STD 119,U
	STD 79,U
	LEAU -280,U

	LDD #$22ee
	STD 119,U
	LDB #$2e
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	LDB #$22
	STD -81,U
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$eebe
	STD -41,U
	LDB #$eb
	STD 119,U
	LDB #$ee
	STD 79,U
	STD 39,U
	STD -1,U
	STD -81,U
	LDD #$2eeb
	STD -121,U
	LEAU -280,U

	LDD #$22ee
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -201,U

	LDB #$2e
	STD 40,U
	LDB #$22
	STD ,U
	RTS

