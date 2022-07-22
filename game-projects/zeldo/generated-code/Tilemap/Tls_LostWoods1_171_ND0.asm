	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_171
	LEAU 481,U

	LDD #$dd4b
	STD 119,U
	LDB #$4e
	STD 79,U
	LDD #$0e4b
	STD -121,U
	LDD #$d1eb
	STD -1,U
	LDD #$d055
	STD -41,U
	LDD #$0054
	STD -81,U
	LDD #$ddbb
	STD 39,U
	LEAU -280,U

	LDD #$d454
	STD -1,U
	LDD #$e555
	STD 79,U
	LDB #$54
	STD 39,U
	LDD #$e445
	STD 119,U
	LDD #$de54
	STD -41,U
	LDA #$dd
	STD -81,U
	STD -121,U
	LEAU -201,U

	LDD #$d145
	STD 40,U
	LDA #$d0
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$ebbb
	STD 119,U
	LDD #$e4b5
	STD 79,U
	LDD #$0454
	STD 39,U
	LDA #$0e
	STD -1,U
	LDD #$ee45
	STD -41,U
	LDA #$be
	STD -81,U
	LDD #$b554
	STD -121,U
	LEAU -280,U

	LDB #$b4
	STD 119,U
	LDD #$e45e
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	LDB #$bb
	STD 79,U
	LDB #$4b
	STD -121,U
	LEAU -201,U

	LDD #$e5b4
	STD 40,U
	STD ,U
	RTS

