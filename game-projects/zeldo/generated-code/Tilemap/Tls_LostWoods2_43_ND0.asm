	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_43
	LEAU 481,U

	LDD #$eebb
	STD 79,U
	STD 39,U
	LDB #$b4
	STD -1,U
	STD -41,U
	STD -81,U
	LDD #$2ebb
	STD 119,U
	LDD #$ee44
	STD -121,U
	LEAU -280,U

	LDD #$2e4b
	STD 39,U
	LDB #$4e
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LDD #$ee44
	STD 119,U
	LDB #$4b
	STD 79,U
	LEAU -201,U

	LDD #$2e4e
	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$ebbb
	STD -81,U
	STD -121,U
	LDB #$44
	STD 79,U
	STD 39,U
	LDB #$4b
	STD -1,U
	STD -41,U
	LDD #$eeb4
	STD 119,U
	LEAU -280,U

	LDD #$ebee
	STD 79,U
	LDB #$eb
	STD 39,U
	STD -1,U
	LDB #$be
	STD 119,U
	LDD #$eeeb
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U
	RTS

