	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_65
	LEAU 481,U

	LDD #$2222
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	LDB #$11
	STD -41,U
	LDB #$00
	STD -81,U
	LDD #$21ee
	STD -121,U
	LEAU -280,U

	LDD #$20be
	STD 119,U
	LDD #$ebbb
	STD -41,U
	LDD #$eebe
	STD 39,U
	LDD #$ebee
	STD -1,U
	LDD #$0ebe
	STD 79,U
	LDD #$eb44
	STD -81,U
	STD -121,U
	LEAU -201,U

	LDD #$bebb
	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$1122
	STD -41,U
	LDA #$22
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	LDD #$0012
	STD -81,U
	LDD #$ee02
	STD -121,U
	LEAU -280,U

	LDB #$e1
	STD 119,U
	LDD #$ebee
	STD 79,U
	LDB #$be
	STD 39,U
	LDA #$44
	STD -81,U
	LDA #$bb
	STD -41,U
	LDA #$be
	STD -1,U
	LDA #$b4
	STD -121,U
	LEAU -201,U

	LDA #$bb
	STD 40,U
	LDB #$eb
	STD ,U
	RTS

