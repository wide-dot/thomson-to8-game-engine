	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_50
	LEAU 481,U

	LDD #$4eb4
	STD -1,U
	LDB #$bb
	STD -41,U
	LDA #$bb
	STD 79,U
	LDB #$b4
	STD 39,U
	LDB #$ee
	STD 119,U
	LDD #$bebb
	STD -81,U
	LDD #$ebee
	STD -121,U
	LEAU -280,U

	LDD #$0000
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LDA #$e0
	STD 79,U
	LDD #$eeee
	STD 119,U
	LEAU -201,U

	LDD #$0011
	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$eeeb
	STD 119,U
	LDD #$bbb4
	STD -1,U
	LDB #$be
	STD -81,U
	LDB #$e4
	STD 79,U
	STD 39,U
	LDD #$4bbb
	STD -41,U
	LDD #$eebe
	STD -121,U
	LEAU -280,U

	LDD #$000e
	STD 79,U
	LDB #$00
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LDD #$eeee
	STD 119,U
	LEAU -201,U

	LDD #$0100
	STD 40,U
	LDD #$1110
	STD ,U
	RTS

