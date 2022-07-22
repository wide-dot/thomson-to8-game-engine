	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_96
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

	LDD #$ddbe
	STD 119,U
	LDD #$d1bb
	STD 39,U
	LDB #$b5
	STD -1,U
	LDD #$ddeb
	STD 79,U
	LDA #$d0
	STD -41,U
	LDB #$ee
	STD -81,U
	STD -121,U
	LEAU -280,U

	LDD #$deeb
	STD 119,U
	LDD #$ebee
	STD 39,U
	LDA #$0e
	STD 79,U
	LDA #$b5
	STD -1,U
	LDB #$e0
	STD -41,U
	LDD #$eb00
	STD -81,U
	LDA #$d5
	STD -121,U
	LEAU -201,U

	LDA #$d0
	STD ,U
	LDA #$de
	STD 40,U
	RTS

