	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_143
	LEAU 481,U

	LDD #$21bb
	STD -41,U
	LDD #$22eb
	STD 79,U
	STD 39,U
	LDB #$be
	STD 119,U
	STD -1,U
	LDD #$21eb
	STD -81,U
	LDD #$11bb
	STD -121,U
	LEAU -280,U

	STD 119,U
	LDB #$be
	STD 79,U
	LDB #$e5
	STD 39,U
	LDD #$215e
	STD -1,U
	STD -41,U
	LDA #$22
	STD -81,U
	LDB #$5b
	STD -121,U
	LEAU -201,U

	LDB #$e5
	STD 40,U
	LDB #$be
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$10ee
	STD 119,U
	LDB #$eb
	STD -1,U
	LDD #$0e4b
	STD -81,U
	STD -121,U
	LDD #$1044
	STD 39,U
	LDD #$1ebe
	STD -41,U
	LDD #$10bb
	STD 79,U
	LEAU -280,U

	LDD #$0eb4
	STD 79,U
	LDB #$4b
	STD 119,U
	LDB #$eb
	STD 39,U
	LDB #$5b
	STD -1,U
	LDD #$1e5e
	STD -41,U
	LDD #$10ee
	STD -81,U
	LDB #$5e
	STD -121,U
	LEAU -201,U

	LDB #$5b
	STD 40,U
	LDB #$eb
	STD ,U
	RTS

