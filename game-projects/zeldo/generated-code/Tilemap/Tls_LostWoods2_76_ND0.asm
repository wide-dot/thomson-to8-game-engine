	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_76
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -280,U

	LDB #$d1
	STD 119,U
	LDD #$1e00
	STD 79,U
	LDD #$e5ee
	STD -1,U
	LDD #$ebe0
	STD 39,U
	LDB #$ee
	STD -41,U
	LDB #$eb
	STD -81,U
	STD -121,U
	LEAU -201,U

	LDD #$0eb5
	STD ,U
	LDD #$0beb
	STD 40,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$dd10
	STD -121,U
	LDB #$dd
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	LDB #$d1
	STD -81,U
	LEAU -280,U

	LDD #$bbee
	STD -81,U
	LDD #$ee00
	STD 79,U
	LDA #$be
	STD 39,U
	LDA #$5b
	STD -1,U
	LDB #$e0
	STD -41,U
	LDD #$dd00
	STD 119,U
	LDD #$bbbe
	STD -121,U
	LEAU -201,U

	LDA #$5b
	STD 40,U
	LDD #$bbbb
	STD ,U
	RTS

