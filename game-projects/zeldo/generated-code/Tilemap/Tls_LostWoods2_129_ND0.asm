	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_129
	LEAU 481,U

	LDD #$bebe
	STD 119,U
	STD 79,U
	LDB #$eb
	STD 39,U
	LDD #$bbee
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -280,U

	STD 119,U
	LDB #$be
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	LDB #$bb
	STD -81,U
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$eeeb
	STD 119,U
	LDB #$ee
	STD 79,U
	STD 39,U
	STD -1,U
	STD -81,U
	LDB #$be
	STD -41,U
	LDD #$beeb
	STD -121,U
	LEAU -280,U

	LDD #$bbee
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -201,U

	LDB #$be
	STD 40,U
	LDB #$bb
	STD ,U
	RTS

