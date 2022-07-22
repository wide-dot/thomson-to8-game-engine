	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_30
	LEAU 481,U

	LDD #$bbb0
	STD -81,U
	LDB #$be
	STD -121,U
	LDB #$e1
	STD -1,U
	LDB #$e0
	STD -41,U
	LDD #$b4e1
	STD 119,U
	STD 79,U
	STD 39,U
	LEAU -280,U

	STD -121,U
	LDD #$bbe0
	STD -41,U
	LDB #$e1
	STD -81,U
	LDB #$be
	STD 119,U
	STD 79,U
	STD 39,U
	LDB #$b0
	STD -1,U
	LEAU -201,U

	LDD #$b4e1
	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$bb12
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	LDB #$11
	STD -81,U
	STD -121,U
	LEAU -280,U

	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	LDB #$12
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U
	RTS

