	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_181
	LEAU 481,U

	LDD #$bbe4
	STD 119,U
	LDD #$44ee
	STD 79,U
	LDB #$e4
	STD 39,U
	LDB #$44
	STD -1,U
	LDD #$ebbe
	STD -81,U
	LDD #$4e4b
	STD -41,U
	LDD #$ebe0
	STD -121,U
	LEAU -280,U

	LDD #$dddd
	STD 79,U
	STD 39,U
	LDB #$d1
	STD -1,U
	LDD #$1e1d
	STD 119,U
	LDD #$dd10
	STD -41,U
	LDB #$ee
	STD -81,U
	STD -121,U
	LEAU -201,U

	LDB #$eb
	STD ,U
	LDB #$be
	STD 40,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$eb4e
	STD 119,U
	LDD #$e4e1
	STD -41,U
	LDD #$ebbe
	STD 39,U
	LDD #$eee0
	STD -1,U
	LDD #$ebee
	STD 79,U
	LDB #$0d
	STD -81,U
	LDD #$eedd
	STD -121,U
	LEAU -280,U

	LDA #$11
	STD 119,U
	LDD #$ddd0
	STD 79,U
	LDD #$eeeb
	STD -81,U
	LDD #$dd0b
	STD -1,U
	LDB #$ee
	STD -41,U
	LDB #$1e
	STD 39,U
	LDD #$bbeb
	STD -121,U
	LEAU -201,U

	LDB #$bb
	STD 40,U
	LDD #$b4be
	STD ,U
	RTS

