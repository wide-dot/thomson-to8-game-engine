	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_32
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	LDA #$01
	STD -121,U
	LDA #$1d
	STD -81,U
	LEAU -280,U

	LDA #$00
	STD 119,U
	LDD #$eeb5
	STD -81,U
	STD -121,U
	LDA #$00
	STD -41,U
	LDB #$ee
	STD 79,U
	LDB #$eb
	STD 39,U
	STD -1,U
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

	LDA #$01
	STD 119,U
	LDD #$00be
	STD 39,U
	LDB #$ee
	STD 79,U
	LDD #$0e55
	STD -1,U
	LDD #$ee5b
	STD -41,U
	LDD #$bebb
	STD -81,U
	LDA #$bb
	STD -121,U
	LEAU -201,U

	LDB #$b0
	STD ,U
	LDB #$5e
	STD 40,U
	RTS

