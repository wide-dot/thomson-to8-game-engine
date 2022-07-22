	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_72
	LEAU 481,U

	LDD #$bb01
	STD 119,U
	STD 79,U
	LDB #$00
	STD 39,U
	LDD #$5ee0
	STD -1,U
	STD -41,U
	LDA #$eb
	STD -121,U
	LDA #$be
	STD -81,U
	LEAU -280,U

	LDD #$eeee
	STD 119,U
	LDD #$000e
	STD 39,U
	LDB #$00
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LDD #$e00e
	STD 79,U
	LEAU -201,U

	LDD #$0011
	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$e011
	STD 119,U
	LDA #$be
	STD 79,U
	STD 39,U
	LDA #$5b
	STD -41,U
	LDA #$bb
	STD -1,U
	LDB #$01
	STD -81,U
	LDA #$ee
	STD -121,U
	LEAU -280,U

	LDB #$00
	STD 119,U
	LDA #$00
	STD 79,U
	LDB #$0e
	STD -41,U
	LDB #$00
	STD -81,U
	STD -121,U
	LDB #$e0
	STD 39,U
	LDB #$ee
	STD -1,U
	LEAU -201,U

	LDD #$0100
	STD 40,U
	LDD #$1110
	STD ,U
	RTS

