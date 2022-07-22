	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_54
	LEAU 481,U

	LDD #$d111
	STD 119,U
	LDD #$1eee
	STD 79,U
	LDD #$ee4e
	STD 39,U
	LDD #$ebbe
	STD -1,U
	LDD #$e4b4
	STD -41,U
	LDD #$eebb
	STD -81,U
	LDB #$ee
	STD -121,U
	LEAU -280,U

	LDB #$22
	STD 119,U
	LDD #$e021
	STD -121,U
	LDD #$0111
	STD 39,U
	LDA #$e1
	STD -1,U
	LDA #$e0
	STD -41,U
	STD -81,U
	LDA #$02
	STD 79,U
	LEAU -201,U

	LDD #$e021
	STD 40,U
	LDB #$22
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$ee44
	STD -81,U
	LDB #$4b
	STD -121,U
	LDB #$e1
	STD 79,U
	LDD #$bebe
	STD 39,U
	LDD #$e44e
	STD -1,U
	LDD #$eebb
	STD -41,U
	LDD #$111d
	STD 119,U
	LEAU -280,U

	LDD #$e2be
	STD 119,U
	LDD #$22e2
	STD 79,U
	LDB #$21
	STD 39,U
	LDB #$22
	STD -121,U
	LDB #$11
	STD -1,U
	LDB #$12
	STD -41,U
	STD -81,U
	LEAU -201,U

	LDB #$22
	STD 40,U
	STD ,U
	RTS

