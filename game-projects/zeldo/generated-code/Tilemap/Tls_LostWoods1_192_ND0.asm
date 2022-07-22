	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_192
	LEAU 481,U

	LDD #$dd00
	STD 119,U
	LDB #$ee
	STD 79,U
	LDD #$22bb
	STD 39,U
	LDD #$0eeb
	STD -81,U
	LDD #$00b4
	STD -41,U
	LDD #$2244
	STD -1,U
	LDD #$eeee
	STD -121,U
	LEAU -280,U

	LDB #$b4
	STD -1,U
	STD -41,U
	LDB #$eb
	STD 119,U
	STD 79,U
	STD 39,U
	LDB #$4e
	STD -81,U
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$20dd
	STD 79,U
	LDA #$d2
	STD 119,U
	LDD #$0e2d
	STD 39,U
	LDD #$0bed
	STD -1,U
	STD -41,U
	LDA #$eb
	STD -81,U
	LDD #$eee2
	STD -121,U
	LEAU -280,U

	LDB #$4b
	STD -121,U
	LDB #$b4
	STD -41,U
	LDB #$be
	STD -81,U
	LDB #$e0
	STD 119,U
	LDB #$ee
	STD 79,U
	LDB #$eb
	STD 39,U
	LDB #$e4
	STD -1,U
	LEAU -201,U

	LDB #$4b
	STD 40,U
	STD ,U
	RTS

