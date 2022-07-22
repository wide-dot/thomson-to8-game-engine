	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_102
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -280,U

	STD 119,U
	STD 79,U
	LDD #$de99
	STD -41,U
	LDD #$dd77
	STD -1,U
	LDB #$ee
	STD 39,U
	LDD #$d799
	STD -81,U
	LDB #$79
	STD -121,U
	LEAU -201,U

	LDD #$d887
	STD 40,U
	LDB #$98
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -280,U

	STD 119,U
	STD 79,U
	LDD #$797d
	STD -41,U
	LDD #$77ed
	STD -1,U
	LDD #$eedd
	STD 39,U
	LDD #$997e
	STD -81,U
	LDD #$979e
	STD -121,U
	LEAU -201,U

	LDA #$98
	STD 40,U
	LDA #$78
	STD ,U
	RTS

