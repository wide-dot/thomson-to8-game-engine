	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_52
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	STD 79,U
	STD 39,U
	LDB #$d2
	STD -1,U
	LDB #$de
	STD -41,U
	STD -81,U
	LDB #$2e
	STD -121,U
	LEAU -280,U

	STD 119,U
	LDB #$be
	STD 79,U
	LDB #$ee
	STD 39,U
	STD -1,U
	LDA #$d2
	STD -41,U
	LDA #$de
	STD -81,U
	STD -121,U
	LEAU -201,U

	LDD #$2ebe
	STD ,U
	LDB #$ee
	STD 40,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$ddee
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LDB #$2e
	STD 79,U
	LDB #$d2
	STD 119,U
	LEAU -280,U

	LDD #$2eeb
	STD 39,U
	LDA #$d2
	STD 79,U
	LDD #$ddee
	STD 119,U
	LDD #$eebb
	STD -1,U
	LDB #$be
	STD -41,U
	STD -81,U
	LDB #$bb
	STD -121,U
	LEAU -201,U

	STD 40,U
	LDB #$b4
	STD ,U
	RTS

