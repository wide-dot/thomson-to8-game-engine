	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_44
	LEAU 481,U

	LDD #$be4e
	STD 119,U
	LDA #$ee
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	LDB #$be
	STD -81,U
	LDB #$bb
	STD -121,U
	LEAU -280,U

	STD 119,U
	STD 79,U
	LDA #$be
	STD 39,U
	STD -1,U
	LDB #$4e
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$ebeb
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	LDB #$ee
	STD -121,U
	LDD #$eeeb
	STD 119,U
	LEAU -280,U

	LDD #$ebee
	STD 119,U
	STD 79,U
	STD 39,U
	LDB #$eb
	STD -1,U
	LDA #$ee
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U
	RTS

