	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_106
	LEAU 481,U

	LDD #$eddd
	STD 119,U
	LDD #$b011
	STD 79,U
	LDD #$4e00
	STD 39,U
	LDD #$4bbb
	STD -41,U
	LDB #$b4
	STD -81,U
	LDD #$bee0
	STD -1,U
	LDB #$b4
	STD -121,U
	LEAU -280,U

	LDA #$eb
	STD 119,U
	LDD #$bb4b
	STD 79,U
	LDD #$44be
	STD -41,U
	LDD #$454e
	STD -1,U
	LDA #$5b
	STD 39,U
	LDD #$54eb
	STD -81,U
	LDD #$455b
	STD -121,U
	LEAU -201,U

	LDB #$5e
	STD 40,U
	LDD #$544e
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	STD 79,U
	LDD #$110d
	STD 39,U
	LDD #$00bd
	STD -1,U
	LDD #$ee4d
	STD -81,U
	LDA #$00
	STD -41,U
	LDA #$eb
	STD -121,U
	LEAU -280,U

	LDD #$5b1d
	STD -41,U
	LDD #$eb0d
	STD 79,U
	LDD #$bbdd
	STD 39,U
	LDD #$be1d
	STD -1,U
	LDD #$ebed
	STD 119,U
	LDD #$5501
	STD -81,U
	LDD #$44e1
	STD -121,U
	LEAU -201,U

	LDD #$b5bb
	STD ,U
	LDD #$b4be
	STD 40,U
	RTS

