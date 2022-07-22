	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_80
	LEAU 481,U

	LDD #$222e
	STD 119,U
	LDB #$2b
	STD -121,U
	LDB #$ee
	STD 79,U
	STD 39,U
	LDB #$eb
	STD -1,U
	LDB #$e4
	STD -41,U
	STD -81,U
	LEAU -280,U

	LDB #$1e
	STD 79,U
	LDB #$12
	STD 39,U
	LDB #$11
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LDB #$2e
	STD 119,U
	LEAU -201,U

	LDB #$12
	STD 40,U
	LDB #$1e
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$111d
	STD 119,U
	STD 79,U
	STD 39,U
	LDD #$21ed
	STD -1,U
	LDB #$e1
	STD -41,U
	STD -81,U
	LDB #$ee
	STD -121,U
	LEAU -280,U

	STD 39,U
	LDD #$114e
	STD 79,U
	LDB #$ee
	STD 119,U
	LDA #$22
	STD -1,U
	STD -41,U
	STD -81,U
	LDB #$e1
	STD -121,U
	LEAU -201,U

	LDD #$111d
	STD ,U
	LDD #$22ed
	STD 40,U
	RTS

