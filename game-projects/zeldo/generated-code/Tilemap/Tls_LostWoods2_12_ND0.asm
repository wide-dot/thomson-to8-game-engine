	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_12
	LEAU 481,U

	LDD #$4bbb
	STD 119,U
	STD 79,U
	LDD #$ee44
	STD -121,U
	LDD #$bebb
	STD -1,U
	LDB #$b4
	STD -41,U
	LDB #$44
	STD -81,U
	LDD #$bbbb
	STD 39,U
	LEAU -280,U

	LDD #$eb4b
	STD 119,U
	LDB #$be
	STD 79,U
	LDD #$bbee
	STD 39,U
	STD -1,U
	STD -41,U
	LDA #$b4
	STD -81,U
	STD -121,U
	LEAU -201,U

	LDD #$4bbe
	STD ,U
	LDD #$44ee
	STD 40,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$eeb4
	STD 119,U
	LDD #$bbbe
	STD -81,U
	LDB #$4e
	STD -1,U
	STD -41,U
	LDD #$eb44
	STD 79,U
	LDB #$4b
	STD 39,U
	LDD #$bbee
	STD -121,U
	LEAU -280,U

	LDA #$b4
	STD 119,U
	LDD #$44eb
	STD 79,U
	LDA #$4b
	STD 39,U
	LDD #$bebe
	STD -81,U
	LDD #$4ebb
	STD -1,U
	LDB #$be
	STD -41,U
	LDD #$eebb
	STD -121,U
	LEAU -201,U

	STD 40,U
	LDB #$b4
	STD ,U
	RTS

