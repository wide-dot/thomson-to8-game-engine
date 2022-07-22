	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods3_67
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	STD 79,U
	STD 39,U
	LDB #$d1
	STD -1,U
	LDB #$11
	STD -41,U
	LDB #$00
	STD -81,U
	STD -121,U
	LEAU -280,U

	LDD #$d10e
	STD 119,U
	LDD #$eee4
	STD -1,U
	STD -41,U
	LDD #$e00e
	STD 39,U
	LDA #$00
	STD 79,U
	LDD #$e4e4
	STD -81,U
	STD -121,U
	LEAU -201,U

	LDD #$464e
	STD ,U
	LDA #$e4
	STD 40,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$dd1e
	STD 79,U
	LDB #$de
	STD 119,U
	LDB #$e4
	STD 39,U
	STD -1,U
	LDB #$e6
	STD -41,U
	LDD #$d146
	STD -81,U
	LDA #$10
	STD -121,U
	LEAU -280,U

	LDD #$ee66
	STD -81,U
	LDD #$00e4
	STD 39,U
	LDD #$e044
	STD -41,U
	LDD #$0046
	STD 119,U
	STD 79,U
	LDB #$4e
	STD -1,U
	LDD #$4e46
	STD -121,U
	LEAU -201,U

	LDB #$44
	STD 40,U
	LDA #$44
	STD ,U
	RTS

