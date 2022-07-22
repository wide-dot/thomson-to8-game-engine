	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods3_143
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

	LDD #$1e00
	STD 79,U
	LDD #$ddd1
	STD 119,U
	LDD #$e4e0
	STD 39,U
	LDD #$e6ee
	STD -1,U
	STD -41,U
	LDB #$e4
	STD -81,U
	STD -121,U
	LEAU -201,U

	LDD #$0e46
	STD ,U
	LDD #$04e4
	STD 40,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$dd10
	STD -121,U
	LDB #$dd
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	LDB #$d1
	STD -81,U
	LEAU -280,U

	LDB #$00
	STD 119,U
	LDA #$ee
	STD 79,U
	LDA #$4e
	STD 39,U
	LDD #$644e
	STD -121,U
	LDB #$e0
	STD -41,U
	LDB #$ee
	STD -81,U
	LDB #$00
	STD -1,U
	LEAU -201,U

	LDD #$4444
	STD ,U
	LDD #$644e
	STD 40,U
	RTS

