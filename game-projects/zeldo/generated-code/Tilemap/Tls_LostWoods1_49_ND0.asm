	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_49
	LEAU 481,U

	LDD #$11b4
	STD 119,U
	LDB #$be
	STD -41,U
	LDD #$1ebb
	STD -121,U
	LDB #$ee
	STD -81,U
	LDD #$1144
	STD 79,U
	LDB #$4b
	STD 39,U
	STD -1,U
	LEAU -280,U

	LDD #$eeee
	STD 79,U
	STD 39,U
	LDB #$bb
	STD 119,U
	LDB #$00
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$eebb
	STD 119,U
	LDB #$b4
	STD -81,U
	STD -121,U
	LDD #$ebbb
	STD 79,U
	STD -41,U
	LDD #$bbeb
	STD 39,U
	LDD #$b4bb
	STD -1,U
	LEAU -280,U

	LDD #$e000
	STD -41,U
	LDD #$eeee
	STD 79,U
	STD 39,U
	LDB #$00
	STD -1,U
	LDD #$ebbe
	STD 119,U
	LDD #$0000
	STD -81,U
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U
	RTS

