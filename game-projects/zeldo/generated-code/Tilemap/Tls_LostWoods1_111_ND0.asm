	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_111
	LEAU 481,U

	LDD #$0ebe
	STD 119,U
	LDD #$dde1
	STD -121,U
	LDD #$1eeb
	STD 39,U
	LDB #$ee
	STD -1,U
	LDD #$d044
	STD -41,U
	LDD #$d1be
	STD -81,U
	LDD #$1ebb
	STD 79,U
	LEAU -280,U

	LDD #$dddd
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LDB #$11
	STD 119,U
	LEAU -201,U

	LDB #$dd
	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$4beb
	STD 119,U
	LDD #$44b4
	STD 39,U
	LDA #$ee
	STD 79,U
	LDA #$b4
	STD -1,U
	LDD #$e4e4
	STD -41,U
	LDD #$0bbe
	STD -81,U
	LDD #$1eeb
	STD -121,U
	LEAU -280,U

	LDD #$d2ee
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
	RTS

