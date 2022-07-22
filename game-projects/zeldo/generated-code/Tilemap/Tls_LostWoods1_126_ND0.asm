	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_126
	LEAU 481,U

	LDD #$11bb
	STD -121,U
	LDA #$21
	STD -41,U
	STD -81,U
	LDA #$22
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	LEAU -280,U

	LDA #$11
	STD 119,U
	LDA #$0e
	STD 39,U
	LDA #$10
	STD 79,U
	LDA #$ee
	STD -1,U
	LDB #$be
	STD -41,U
	LDD #$ebeb
	STD -81,U
	LDB #$54
	STD -121,U
	LEAU -201,U

	LDD #$0b44
	STD 40,U
	LDB #$ee
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$0eb4
	STD -81,U
	STD -121,U
	LDA #$1e
	STD -41,U
	LDA #$10
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	LEAU -280,U

	LDD #$bb55
	STD -81,U
	LDD #$ebb4
	STD 79,U
	STD 39,U
	LDB #$bb
	STD -1,U
	LDD #$bbee
	STD -41,U
	LDD #$0eb4
	STD 119,U
	LDD #$be44
	STD -121,U
	LEAU -201,U

	LDD #$44ee
	STD ,U
	LDA #$e4
	STD 40,U
	RTS

