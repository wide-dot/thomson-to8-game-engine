	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_60
	LEAU 481,U

	LDD #$4bee
	STD 119,U
	LDA #$bb
	STD -121,U
	LDA #$ee
	STD -1,U
	STD -41,U
	STD -81,U
	LDA #$be
	STD 79,U
	STD 39,U
	LEAU -280,U

	LDA #$bb
	STD 119,U
	LDA #$44
	STD 79,U
	STD 39,U
	LDB #$be
	STD -1,U
	LDB #$bb
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -201,U

	LDA #$b4
	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$beee
	STD -121,U
	LDA #$ee
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	LEAU -280,U

	LDA #$bb
	STD 79,U
	STD 39,U
	STD -1,U
	LDA #$be
	STD 119,U
	LDA #$4b
	STD -41,U
	LDB #$bb
	STD -81,U
	LDA #$44
	STD -121,U
	LEAU -201,U

	LDD #$4b44
	STD 40,U
	STD ,U
	RTS

