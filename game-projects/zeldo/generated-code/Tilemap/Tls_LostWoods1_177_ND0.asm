	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_177
	LEAU 481,U

	LDD #$110e
	STD -1,U
	LDB #$0d
	STD -41,U
	LDD #$010e
	STD 39,U
	LDD #$0010
	STD 119,U
	STD 79,U
	LDD #$11ed
	STD -81,U
	LDD #$00dd
	STD -121,U
	LEAU -280,U

	LDD #$b011
	STD 39,U
	LDD #$eddd
	STD 79,U
	LDA #$ee
	STD 119,U
	LDD #$4e00
	STD -1,U
	LDD #$bee0
	STD -41,U
	LDD #$4bbb
	STD -81,U
	LDB #$b4
	STD -121,U
	LEAU -201,U

	LDA #$eb
	STD ,U
	LDA #$be
	STD 40,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$0edd
	STD -121,U
	LDA #$11
	STD 39,U
	STD -1,U
	LDA #$10
	STD -41,U
	LDA #$00
	STD -81,U
	LDD #$11ee
	STD 119,U
	LDB #$ed
	STD 79,U
	LEAU -280,U

	LDD #$eddd
	STD 119,U
	LDA #$dd
	STD 79,U
	STD 39,U
	LDD #$00bd
	STD -41,U
	LDD #$110d
	STD -1,U
	LDD #$004d
	STD -81,U
	LDA #$ee
	STD -121,U
	LEAU -201,U

	LDA #$eb
	STD 40,U
	LDB #$ed
	STD ,U
	RTS

