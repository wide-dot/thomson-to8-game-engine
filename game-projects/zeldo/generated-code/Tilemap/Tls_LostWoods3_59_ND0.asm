	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods3_59
	LEAU 481,U

	LDD #$dd00
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	LDB #$0e
	STD -121,U
	LEAU -280,U

	LDB #$ee
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$dd4e
	STD 119,U
	LDB #$e4
	STD 79,U
	LDA #$d0
	STD -41,U
	LDB #$ee
	STD -81,U
	STD -121,U
	LDD #$d144
	STD 39,U
	LDB #$46
	STD -1,U
	LEAU -280,U

	LDD #$dee4
	STD 119,U
	LDD #$e600
	STD -81,U
	LDD #$e4ee
	STD 39,U
	LDA #$46
	STD -1,U
	LDB #$e0
	STD -41,U
	LDD #$0eee
	STD 79,U
	LDD #$d600
	STD -121,U
	LEAU -201,U

	LDA #$d0
	STD ,U
	LDA #$de
	STD 40,U
	RTS

