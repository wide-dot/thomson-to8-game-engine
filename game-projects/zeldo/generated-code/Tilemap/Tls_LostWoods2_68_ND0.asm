	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_68
	LEAU 481,U

	LDD #$ddd2
	STD 119,U
	LDB #$22
	STD 79,U
	LDD #$22ee
	STD -81,U
	STD -121,U
	LDB #$22
	STD 39,U
	LDB #$2e
	STD -1,U
	STD -41,U
	LEAU -280,U

	LDD #$eeee
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

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$2eee
	STD -121,U
	LDA #$22
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	LDD #$dd22
	STD 119,U
	LDB #$2e
	STD 79,U
	LEAU -280,U

	LDD #$eeee
	STD 119,U
	LDB #$eb
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	LDB #$e4
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U
	RTS

