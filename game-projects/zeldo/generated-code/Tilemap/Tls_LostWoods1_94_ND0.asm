	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_94
	LEAU 481,U

	LDD #$b4bb
	STD 119,U
	LDD #$eebe
	STD -81,U
	LDD #$4bbb
	STD 39,U
	LDB #$4e
	STD -1,U
	LDA #$be
	STD -41,U
	LDD #$44bb
	STD 79,U
	LDD #$bbeb
	STD -121,U
	LEAU -280,U

	LDD #$0000
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LDD #$eee0
	STD 79,U
	LDB #$00
	STD 39,U
	LDD #$bbee
	STD 119,U
	LEAU -201,U

	LDD #$0000
	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$b4ee
	STD -121,U
	LDD #$bbbb
	STD 79,U
	STD -1,U
	LDA #$eb
	STD 39,U
	LDD #$bb4b
	STD -41,U
	LDD #$b4bb
	STD -81,U
	LDD #$bbee
	STD 119,U
	LEAU -280,U

	LDA #$be
	STD 119,U
	LDD #$0000
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LDA #$ee
	STD 79,U
	STD 39,U
	LEAU -201,U

	LDD #$0001
	STD 40,U
	LDB #$11
	STD ,U
	RTS

