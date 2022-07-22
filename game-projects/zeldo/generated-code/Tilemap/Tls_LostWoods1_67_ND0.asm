	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_67
	LEAU 481,U

	LDD #$1ddd
	STD -81,U
	LDA #$dd
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	LDA #$01
	STD -121,U
	LEAU -280,U

	LDA #$00
	STD 119,U
	LDB #$ee
	STD 79,U
	LDB #$eb
	STD 39,U
	STD -1,U
	LDB #$b4
	STD -41,U
	LDA #$ee
	STD -81,U
	STD -121,U
	LEAU -201,U

	LDD #$bebb
	STD 40,U
	LDB #$eb
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$1ddd
	STD -121,U
	LDA #$dd
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	LEAU -280,U

	LDD #$ee45
	STD -41,U
	LDD #$00ee
	STD 79,U
	LDB #$be
	STD 39,U
	LDD #$0e44
	STD -1,U
	LDD #$01dd
	STD 119,U
	LDD #$be55
	STD -81,U
	LDD #$bb5b
	STD -121,U
	LEAU -201,U

	LDB #$b0
	STD ,U
	LDB #$4e
	STD 40,U
	RTS

