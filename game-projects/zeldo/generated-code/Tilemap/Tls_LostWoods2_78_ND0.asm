	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_78
	LEAU 481,U

	LDD #$115b
	STD -41,U
	LDD #$ddbe
	STD 39,U
	LDD #$d15b
	STD -1,U
	LDD #$dde1
	STD 119,U
	LDB #$ee
	STD 79,U
	LDD #$0055
	STD -81,U
	LDB #$b5
	STD -121,U
	LEAU -280,U

	LDD #$0e5b
	STD 79,U
	LDB #$bb
	STD 119,U
	STD 39,U
	LDD #$ebee
	STD -1,U
	LDB #$bb
	STD -41,U
	LDB #$55
	STD -81,U
	STD -121,U
	LEAU -201,U

	LDD #$bebb
	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$dedd
	STD 119,U
	LDD #$eb1d
	STD 39,U
	STD -1,U
	LDD #$1edd
	STD 79,U
	LDD #$e5e1
	STD -41,U
	LDA #$b5
	STD -81,U
	LDB #$e0
	STD -121,U
	LEAU -280,U

	STD 119,U
	STD 79,U
	LDD #$55be
	STD -81,U
	LDA #$be
	STD -1,U
	LDA #$bb
	STD -41,U
	LDA #$eb
	STD 39,U
	LDA #$b5
	STD -121,U
	LEAU -201,U

	LDD #$bbeb
	STD ,U
	LDB #$be
	STD 40,U
	RTS

