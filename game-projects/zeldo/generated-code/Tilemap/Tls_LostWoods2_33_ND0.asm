	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_33
	LEAU 481,U

	LDD #$4e44
	STD -121,U
	LDB #$bb
	STD 119,U
	STD 79,U
	STD 39,U
	LDB #$b4
	STD -1,U
	STD -41,U
	STD -81,U
	LEAU -280,U

	LDB #$44
	STD 119,U
	LDD #$be4b
	STD 79,U
	LDA #$bb
	STD 39,U
	LDB #$4e
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -201,U

	STD 40,U
	LDA #$be
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$eeb4
	STD 119,U
	LDB #$44
	STD 79,U
	STD 39,U
	LDD #$ebbb
	STD -81,U
	STD -121,U
	LDB #$4b
	STD -1,U
	STD -41,U
	LEAU -280,U

	LDB #$ee
	STD 79,U
	LDB #$eb
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LDB #$be
	STD 119,U
	LEAU -201,U

	LDB #$eb
	STD 40,U
	STD ,U
	RTS

