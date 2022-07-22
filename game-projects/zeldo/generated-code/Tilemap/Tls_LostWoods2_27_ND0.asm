	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_27
	LEAU 481,U

	LDD #$2e4e
	STD 119,U
	LDD #$eebe
	STD -81,U
	LDB #$bb
	STD -121,U
	LDB #$4e
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	LEAU -280,U

	LDD #$2ebb
	STD 39,U
	STD -1,U
	LDA #$ee
	STD 119,U
	STD 79,U
	LDD #$2e4e
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$eeeb
	STD 119,U
	LDA #$eb
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	LDB #$ee
	STD -121,U
	LEAU -280,U

	LDD #$eeeb
	STD -41,U
	STD -81,U
	STD -121,U
	LDD #$ebee
	STD 119,U
	STD 79,U
	STD 39,U
	LDB #$eb
	STD -1,U
	LEAU -201,U

	LDA #$ee
	STD 40,U
	STD ,U
	RTS

