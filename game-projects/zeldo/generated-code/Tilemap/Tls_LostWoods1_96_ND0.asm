	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_96
	LEAU 481,U

	LDD #$bb00
	STD 119,U
	STD -41,U
	LDA #$4b
	STD 39,U
	LDA #$be
	STD 79,U
	LDB #$0e
	STD -121,U
	LDD #$4400
	STD -1,U
	LDA #$ee
	STD -81,U
	LEAU -280,U

	LDD #$beee
	STD 119,U
	LDA #$ee
	STD 79,U
	STD 39,U
	LDA #$00
	STD -41,U
	STD -81,U
	STD -121,U
	LDA #$0e
	STD -1,U
	LEAU -201,U

	LDA #$00
	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$e0be
	STD 119,U
	LDB #$bb
	STD 39,U
	LDB #$b4
	STD -1,U
	LDB #$eb
	STD 79,U
	STD -41,U
	LDB #$ee
	STD -81,U
	STD -121,U
	LEAU -280,U

	LDD #$eeeb
	STD 119,U
	LDB #$ee
	STD 79,U
	STD 39,U
	STD -1,U
	LDB #$e0
	STD -41,U
	LDB #$00
	STD -81,U
	LDA #$0e
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U
	RTS

