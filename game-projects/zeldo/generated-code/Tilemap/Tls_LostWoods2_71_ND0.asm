	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_71
	LEAU 481,U

	LDD #$00b5
	STD 119,U
	LDB #$be
	STD -41,U
	LDB #$55
	STD 79,U
	LDB #$5b
	STD 39,U
	STD -1,U
	LDB #$ee
	STD -81,U
	LDD #$0ebb
	STD -121,U
	LEAU -280,U

	LDA #$ee
	STD 119,U
	LDB #$ee
	STD 79,U
	STD 39,U
	LDB #$00
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$bebb
	STD 119,U
	LDA #$eb
	STD 79,U
	STD -41,U
	LDD #$eeb5
	STD -81,U
	STD -121,U
	LDD #$b5bb
	STD -1,U
	LDD #$bbeb
	STD 39,U
	LEAU -280,U

	LDD #$ebbe
	STD 119,U
	LDD #$0000
	STD -81,U
	STD -121,U
	LDA #$ee
	STD -1,U
	LDA #$e0
	STD -41,U
	LDD #$eeee
	STD 79,U
	STD 39,U
	LEAU -201,U

	LDD #$0000
	STD 40,U
	STD ,U
	RTS

