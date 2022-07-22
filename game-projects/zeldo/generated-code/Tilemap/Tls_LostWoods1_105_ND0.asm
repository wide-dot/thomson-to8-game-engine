	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_105
	LEAU 481,U

	LDD #$dee0
	STD -41,U
	STD -81,U
	LDB #$ee
	STD -121,U
	LDD #$d01d
	STD 39,U
	LDD #$de01
	STD -1,U
	LDD #$dddd
	STD 119,U
	STD 79,U
	LEAU -280,U

	LDB #$4b
	STD 79,U
	LDB #$4e
	STD 39,U
	LDB #$bb
	STD 119,U
	STD -1,U
	LDD #$d1eb
	STD -41,U
	LDD #$d055
	STD -81,U
	LDD #$0054
	STD -121,U
	LEAU -201,U

	LDD #$0e4b
	STD 40,U
	LDD #$e445
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$44bb
	STD -121,U
	LDD #$111b
	STD 39,U
	LDD #$e00b
	STD -1,U
	LDD #$4eeb
	STD -41,U
	LDA #$44
	STD -81,U
	LDD #$ddd0
	STD 119,U
	LDB #$de
	STD 79,U
	LEAU -280,U

	LDD #$4bbe
	STD 119,U
	LDD #$ebbb
	STD 79,U
	LDD #$e4b5
	STD 39,U
	LDD #$0e54
	STD -41,U
	LDA #$04
	STD -1,U
	LDD #$ee45
	STD -81,U
	LDA #$be
	STD -121,U
	LEAU -201,U

	LDD #$b554
	STD 40,U
	LDB #$b4
	STD ,U
	RTS

