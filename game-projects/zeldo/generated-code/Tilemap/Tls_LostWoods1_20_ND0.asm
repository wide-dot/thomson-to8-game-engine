	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_20
	LEAU 481,U

	LDD #$bb4b
	STD 39,U
	LDB #$44
	STD -1,U
	LDD #$bebb
	STD 119,U
	LDB #$be
	STD 79,U
	LDD #$4bbb
	STD -41,U
	LDB #$ee
	STD -81,U
	LDD #$b4be
	STD -121,U
	LEAU -280,U

	LDA #$eb
	STD 119,U
	LDD #$000e
	STD -1,U
	LDB #$00
	STD -41,U
	STD -81,U
	STD -121,U
	LDD #$eeee
	STD 79,U
	STD 39,U
	LEAU -201,U

	LDD #$0000
	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$b411
	STD 119,U
	LDD #$ebe1
	STD -1,U
	LDA #$b4
	STD 79,U
	STD 39,U
	LDA #$bb
	STD -41,U
	LDA #$be
	STD -81,U
	LDB #$ee
	STD -121,U
	LEAU -280,U

	LDA #$ee
	STD 79,U
	STD 39,U
	LDA #$be
	STD 119,U
	LDA #$00
	STD -1,U
	STD -41,U
	STD -81,U
	LDB #$0e
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U
	RTS

