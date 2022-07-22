	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_6
	LEAU 481,U

	LDD #$2211
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	LDB #$1e
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

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$22bb
	STD 39,U
	LDB #$b4
	STD -1,U
	LDB #$ee
	STD 119,U
	LDB #$eb
	STD 79,U
	STD -41,U
	LDB #$ee
	STD -81,U
	STD -121,U
	LEAU -280,U

	LDB #$eb
	STD 119,U
	LDD #$2e00
	STD -81,U
	STD -121,U
	LDD #$20ee
	STD 39,U
	STD -1,U
	LDB #$e0
	STD -41,U
	LDD #$21ee
	STD 79,U
	LEAU -201,U

	LDD #$2000
	STD 40,U
	STD ,U
	RTS

