	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods3_97
	LEAU 481,U

	LDD #$d2e2
	STD 119,U
	LDD #$d666
	STD -41,U
	STD -121,U
	LDD #$dd6d
	STD 39,U
	LDD #$deee
	STD -1,U
	LDD #$d262
	STD 79,U
	LDD #$d6ee
	STD -81,U
	LEAU -280,U

	LDD #$e6e6
	STD -81,U
	LDD #$d666
	STD 79,U
	LDD #$eeee
	STD 39,U
	STD -1,U
	LDD #$e666
	STD -41,U
	STD -121,U
	LDD #$d6ee
	STD 119,U
	LEAU -201,U

	LDD #$dded
	STD ,U
	LDD #$de6e
	STD 40,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$222d
	STD 119,U
	LDA #$2e
	STD 79,U
	LDD #$dedd
	STD 39,U
	LDD #$eeed
	STD -1,U
	LDB #$ee
	STD -81,U
	LDD #$666e
	STD -41,U
	LDD #$6eee
	STD -121,U
	LEAU -280,U

	LDA #$ee
	STD 119,U
	STD 39,U
	LDB #$e6
	STD -1,U
	LDD #$6e66
	STD -121,U
	LDA #$66
	STD -41,U
	STD -81,U
	LDD #$6eee
	STD 79,U
	LEAU -201,U

	LDA #$ee
	STD 40,U
	LDD #$dedd
	STD ,U
	RTS

