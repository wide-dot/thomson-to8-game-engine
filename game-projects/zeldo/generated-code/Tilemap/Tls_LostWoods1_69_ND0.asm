	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_69
	LEAU 481,U

	LDD #$dde1
	STD 119,U
	LDB #$ee
	STD 79,U
	LDB #$be
	STD 39,U
	LDD #$d14b
	STD -1,U
	LDA #$11
	STD -41,U
	LDD #$0044
	STD -81,U
	LDB #$54
	STD -121,U
	LEAU -280,U

	LDD #$0e5b
	STD 119,U
	LDB #$4b
	STD 79,U
	LDB #$bb
	STD 39,U
	LDA #$eb
	STD -41,U
	LDB #$ee
	STD -1,U
	LDB #$44
	STD -81,U
	STD -121,U
	LEAU -201,U

	LDD #$bebb
	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$e4e1
	STD -41,U
	LDD #$1edd
	STD 79,U
	LDD #$eb1d
	STD 39,U
	STD -1,U
	LDD #$dedd
	STD 119,U
	LDD #$b4e1
	STD -81,U
	LDB #$e0
	STD -121,U
	LEAU -280,U

	STD 119,U
	STD 79,U
	LDD #$bbbe
	STD -41,U
	LDA #$be
	STD -1,U
	LDA #$eb
	STD 39,U
	LDA #$44
	STD -81,U
	LDA #$b4
	STD -121,U
	LEAU -201,U

	LDA #$bb
	STD 40,U
	LDB #$eb
	STD ,U
	RTS

