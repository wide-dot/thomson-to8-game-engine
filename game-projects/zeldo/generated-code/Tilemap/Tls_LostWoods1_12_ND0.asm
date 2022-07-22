	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_12
	LEAU 481,U

	LDD #$4422
	STD -1,U
	LDA #$be
	STD 79,U
	STD -121,U
	LDA #$4b
	STD 39,U
	LDA #$bb
	STD 119,U
	STD -41,U
	LDA #$ee
	STD -81,U
	LEAU -280,U

	LDD #$00e0
	STD -41,U
	STD -81,U
	STD -121,U
	LDD #$ee02
	STD 79,U
	LDB #$01
	STD 39,U
	LDD #$0ee1
	STD -1,U
	LDD #$be22
	STD 119,U
	LEAU -201,U

	LDD #$00e0
	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$ee22
	STD -121,U
	LDA #$e1
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	LDA #$11
	STD 119,U
	LEAU -280,U

	LDA #$ee
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	LDA #$0e
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U
	RTS

