	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods3_94
	LEAU 481,U

	LDD #$4400
	STD 119,U
	STD -41,U
	LDA #$64
	STD 39,U
	LDA #$4e
	STD 79,U
	LDB #$0e
	STD -121,U
	LDD #$6600
	STD -1,U
	LDA #$ee
	STD -81,U
	LEAU -280,U

	LDD #$00ee
	STD -41,U
	STD -81,U
	STD -121,U
	LDA #$ee
	STD 79,U
	STD 39,U
	LDA #$0e
	STD -1,U
	LDA #$4e
	STD 119,U
	LEAU -201,U

	LDA #$00
	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$e04e
	STD 119,U
	LDB #$44
	STD 39,U
	LDB #$46
	STD -1,U
	LDB #$e4
	STD 79,U
	STD -41,U
	LDB #$ee
	STD -81,U
	STD -121,U
	LEAU -280,U

	LDD #$ee00
	STD -81,U
	LDB #$e4
	STD 119,U
	LDB #$ee
	STD 79,U
	STD 39,U
	STD -1,U
	LDB #$e0
	STD -41,U
	LDD #$0e00
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U
	RTS

