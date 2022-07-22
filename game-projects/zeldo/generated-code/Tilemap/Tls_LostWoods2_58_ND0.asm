	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_58
	LEAU 481,U

	LDD #$101d
	STD -81,U
	LDB #$dd
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	LDB #$01
	STD -121,U
	LEAU -280,U

	LDB #$00
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	LDD #$00ee
	STD -121,U
	LDA #$10
	STD -81,U
	LEAU -201,U

	LDD #$00be
	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$0e1d
	STD -121,U
	LDB #$dd
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	LEAU -280,U

	LDB #$ee
	STD -41,U
	LDB #$01
	STD 119,U
	LDB #$00
	STD 79,U
	STD 39,U
	LDB #$0e
	STD -1,U
	LDB #$be
	STD -81,U
	LDB #$bb
	STD -121,U
	LEAU -201,U

	LDA #$eb
	STD ,U
	LDA #$ee
	STD 40,U
	RTS

