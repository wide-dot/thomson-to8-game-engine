	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_79
	LEAU 481,U

	LDD #$deb5
	STD -1,U
	LDA #$d5
	STD 39,U
	LDD #$ebbb
	STD 119,U
	LDB #$b5
	STD 79,U
	LDA #$dd
	STD -41,U
	STD -81,U
	LDD #$d15b
	STD -121,U
	LEAU -280,U

	LDA #$d0
	STD 119,U
	LDD #$deb5
	STD 79,U
	LDD #$1ebb
	STD 39,U
	STD -1,U
	LDD #$202e
	STD -81,U
	LDD #$1ee5
	STD -41,U
	LDD #$d222
	STD -121,U
	LEAU -201,U

	LDA #$dd
	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$e5bb
	STD 119,U
	LDB #$be
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	LDB #$5b
	STD -81,U
	LDD #$ebb5
	STD -121,U
	LEAU -280,U

	LDD #$22eb
	STD -121,U
	LDD #$bbb5
	STD 79,U
	LDD #$5b5b
	STD 39,U
	LDB #$55
	STD -1,U
	LDD #$55bb
	STD -41,U
	LDA #$ee
	STD -81,U
	LDD #$ebb5
	STD 119,U
	LEAU -201,U

	LDD #$dd2e
	STD ,U
	LDD #$d20b
	STD 40,U
	RTS

