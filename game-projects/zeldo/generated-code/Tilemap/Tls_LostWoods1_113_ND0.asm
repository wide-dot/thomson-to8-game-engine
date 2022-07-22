	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_113
	LEAU 481,U

	LDD #$bbe4
	STD 119,U
	LDD #$44ee
	STD 79,U
	LDB #$e4
	STD 39,U
	LDD #$ebe0
	STD -121,U
	LDD #$4e4b
	STD -41,U
	LDD #$ebbe
	STD -81,U
	LDD #$4444
	STD -1,U
	LEAU -280,U

	LDD #$1e1d
	STD 119,U
	LDD #$dddd
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$eb4e
	STD 119,U
	LDB #$ee
	STD 79,U
	LDB #$be
	STD 39,U
	LDD #$eee0
	STD -1,U
	LDD #$e4e1
	STD -41,U
	LDD #$eb0d
	STD -81,U
	LDD #$eedd
	STD -121,U
	LEAU -280,U

	LDA #$dd
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LDA #$11
	STD 119,U
	LEAU -201,U

	LDA #$dd
	STD 40,U
	STD ,U
	RTS

