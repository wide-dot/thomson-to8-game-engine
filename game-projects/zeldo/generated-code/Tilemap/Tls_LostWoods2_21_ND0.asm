	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_21
	LEAU 481,U

	LDD #$0e4e
	STD -1,U
	STD -41,U
	LDA #$ee
	STD 119,U
	STD 79,U
	STD 39,U
	LDD #$00be
	STD -81,U
	LDB #$bb
	STD -121,U
	LEAU -280,U

	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	LDB #$4e
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -201,U

	STD 40,U
	LDA #$10
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$bbeb
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	LDA #$eb
	STD -41,U
	STD -81,U
	LDB #$ee
	STD -121,U
	LEAU -280,U

	STD 119,U
	STD 79,U
	LDD #$0eeb
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LDD #$eeee
	STD 39,U
	LEAU -201,U

	LDD #$0eeb
	STD 40,U
	STD ,U
	RTS

