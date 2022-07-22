	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods3_151
	LEAU 481,U

	LDD #$2233
	STD -1,U
	STD -41,U
	LDD #$2e34
	STD 39,U
	LDB #$4e
	STD 119,U
	STD 79,U
	LDD #$22e3
	STD -81,U
	LDB #$ee
	STD -121,U
	LEAU -280,U

	LDD #$d22e
	STD 79,U
	STD 39,U
	STD -1,U
	LDD #$22ee
	STD 119,U
	LDD #$dd2e
	STD -41,U
	LDB #$22
	STD -81,U
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$ee3e
	STD -1,U
	LDB #$33
	STD -81,U
	LDD #$e3e4
	STD 119,U
	LDB #$e3
	STD 79,U
	STD 39,U
	LDD #$ee4e
	STD -41,U
	LDD #$2e34
	STD -121,U
	LEAU -280,U

	LDD #$d2ee
	STD -121,U
	LDD #$22e3
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	LDB #$ee
	STD -41,U
	STD -81,U
	LEAU -201,U

	LDD #$dd2e
	STD 40,U
	LDB #$22
	STD ,U
	RTS

