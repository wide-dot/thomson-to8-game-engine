	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_116
	LEAU 481,U

	LDD #$222e
	STD 119,U
	STD 79,U
	LDB #$ee
	STD 39,U
	STD -1,U
	LDD #$12e1
	STD -41,U
	LDA #$11
	STD -81,U
	LDB #$ed
	STD -121,U
	LEAU -280,U

	LDD #$121d
	STD 119,U
	LDD #$eedd
	STD 39,U
	STD -1,U
	LDA #$2e
	STD 79,U
	LDA #$11
	STD -41,U
	STD -81,U
	LDA #$dd
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$21dd
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	LDA #$11
	STD -41,U
	LDA #$2e
	STD -121,U
	LDA #$12
	STD -81,U
	LEAU -280,U

	LDA #$11
	STD -1,U
	LDA #$e1
	STD 39,U
	LDA #$ee
	STD 119,U
	STD 79,U
	LDA #$1d
	STD -41,U
	LDA #$dd
	STD -81,U
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U
	RTS

