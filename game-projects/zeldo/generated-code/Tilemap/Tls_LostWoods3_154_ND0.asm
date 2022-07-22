	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods3_154
	LEAU 481,U

	LDD #$d164
	STD -1,U
	LDD #$dd4e
	STD 39,U
	LDB #$e1
	STD 119,U
	LDB #$ee
	STD 79,U
	LDD #$1164
	STD -41,U
	LDD #$0066
	STD -81,U
	STD -121,U
	LEAU -280,U

	LDD #$0e64
	STD 119,U
	STD 79,U
	LDB #$44
	STD 39,U
	LDD #$e4ee
	STD -1,U
	LDB #$44
	STD -41,U
	LDB #$66
	STD -81,U
	STD -121,U
	LEAU -201,U

	LDD #$4e44
	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$dedd
	STD 119,U
	LDA #$1e
	STD 79,U
	LDD #$e41d
	STD 39,U
	STD -1,U
	LDD #$46e1
	STD -81,U
	LDB #$e0
	STD -121,U
	LDD #$e6e1
	STD -41,U
	LEAU -280,U

	LDD #$46e0
	STD 119,U
	STD 79,U
	LDD #$e44e
	STD 39,U
	LDA #$4e
	STD -1,U
	LDA #$44
	STD -41,U
	LDA #$46
	STD -121,U
	LDA #$66
	STD -81,U
	LEAU -201,U

	LDD #$44e4
	STD ,U
	LDB #$4e
	STD 40,U
	RTS

