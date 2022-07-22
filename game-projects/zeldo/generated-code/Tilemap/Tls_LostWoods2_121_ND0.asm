	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_121
	LEAU 481,U

	LDD #$eebe
	STD 119,U
	LDD #$beeb
	STD 39,U
	LDB #$be
	STD 79,U
	LDD #$ebee
	STD -1,U
	STD -41,U
	LDA #$ee
	STD -81,U
	STD -121,U
	LEAU -280,U

	STD 119,U
	STD -41,U
	LDB #$eb
	STD -81,U
	LDB #$ee
	STD -121,U
	LDA #$be
	STD 79,U
	LDA #$eb
	STD -1,U
	LDD #$bebe
	STD 39,U
	LEAU -201,U

	LDD #$eeee
	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$eebe
	STD -41,U
	LDB #$eb
	STD 119,U
	LDB #$ee
	STD 79,U
	STD 39,U
	STD -1,U
	LDB #$eb
	STD -121,U
	LDD #$beee
	STD -81,U
	LEAU -280,U

	STD -81,U
	LDA #$ee
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	LDA #$eb
	STD 119,U
	LDD #$eebe
	STD -121,U
	LEAU -201,U

	LDB #$eb
	STD ,U
	LDD #$ebee
	STD 40,U
	RTS

