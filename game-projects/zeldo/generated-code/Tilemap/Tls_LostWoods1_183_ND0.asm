	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_183
	LEAU 481,U

	LDD #$1101
	STD 119,U
	LDD #$0110
	STD -121,U
	LDD #$0011
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	LDA #$10
	STD 79,U
	LEAU -280,U

	LDD #$1100
	STD 119,U
	STD 79,U
	STD 39,U
	LDD #$10ee
	STD -1,U
	LDD #$00dd
	STD -81,U
	LDB #$ee
	STD -41,U
	LDD #$eedd
	STD -121,U
	LEAU -201,U

	STD 40,U
	LDA #$dd
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$0011
	STD 119,U
	LDB #$10
	STD 79,U
	STD 39,U
	LDD #$110e
	STD -81,U
	STD -121,U
	LDD #$0100
	STD -41,U
	LDA #$00
	STD -1,U
	LEAU -280,U

	LDD #$110e
	STD 119,U
	LDD #$eddd
	STD -81,U
	STD -121,U
	LDD #$00ed
	STD 39,U
	LDA #$0e
	STD -1,U
	LDB #$dd
	STD -41,U
	LDD #$10ee
	STD 79,U
	LEAU -201,U

	LDD #$dddd
	STD 40,U
	STD ,U
	RTS

