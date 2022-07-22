	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_29
	LEAU 481,U

	LDD #$bbb4
	STD -121,U
	LDD #$ebbb
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	LEAU -280,U

	LDD #$bbb4
	STD 119,U
	STD 79,U
	STD 39,U
	LDD #$ebbb
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$4b4e
	STD -41,U
	STD -81,U
	STD -121,U
	LDD #$bb4b
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	LEAU -280,U

	STD -81,U
	STD -121,U
	LDD #$4b4e
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	LEAU -201,U

	LDD #$bb4b
	STD 40,U
	STD ,U
	RTS

