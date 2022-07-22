	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_191
	LEAU 481,U

	LDD #$dd0d
	STD 119,U
	LDD #$d0be
	STD -81,U
	STD -121,U
	LDD #$ddb0
	STD 39,U
	LDD #$d24e
	STD -1,U
	LDB #$be
	STD -41,U
	LDD #$dde2
	STD 79,U
	LEAU -280,U

	LDD #$2eee
	STD 119,U
	LDA #$0b
	STD 79,U
	LDA #$ee
	STD -41,U
	LDA #$e4
	STD 39,U
	STD -1,U
	LDA #$eb
	STD -81,U
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$b400
	STD -1,U
	LDD #$0e2d
	STD 79,U
	LDD #$eb22
	STD 39,U
	LDD #$d0dd
	STD 119,U
	LDD #$bbe0
	STD -41,U
	LDD #$4eee
	STD -81,U
	LDA #$4b
	STD -121,U
	LEAU -280,U

	LDA #$be
	STD -121,U
	LDA #$e4
	STD -41,U
	LDA #$44
	STD -81,U
	LDA #$eb
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	LEAU -201,U

	LDA #$ee
	STD 40,U
	STD ,U
	RTS

