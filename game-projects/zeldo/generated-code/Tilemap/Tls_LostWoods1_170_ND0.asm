	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_170
	LEAU 481,U

	LDD #$0100
	STD 119,U
	STD 79,U
	LDD #$e010
	STD -1,U
	STD -41,U
	LDB #$11
	STD -81,U
	STD -121,U
	LDD #$0010
	STD 39,U
	LEAU -280,U

	LDD #$ee11
	STD 119,U
	LDD #$de00
	STD 79,U
	STD 39,U
	LDD #$ddde
	STD -81,U
	LDB #$dd
	STD -121,U
	LDB #$e0
	STD -1,U
	LDB #$ee
	STD -41,U
	LEAU -201,U

	LDB #$dd
	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$0110
	STD -121,U
	LDB #$00
	STD -81,U
	LDD #$1101
	STD 119,U
	STD 79,U
	LDB #$00
	STD 39,U
	STD -1,U
	STD -41,U
	LEAU -280,U

	LDD #$ddee
	STD -121,U
	LDD #$e001
	STD 39,U
	LDA #$ee
	STD -1,U
	LDD #$de00
	STD -41,U
	LDA #$dd
	STD -81,U
	LDD #$0011
	STD 119,U
	STD 79,U
	LEAU -201,U

	LDD #$ddde
	STD 40,U
	LDB #$dd
	STD ,U
	RTS

