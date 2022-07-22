	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_5
	LEAU 481,U

	LDD #$004e
	STD 119,U
	LDA #$0e
	STD 79,U
	LDA #$ee
	STD 39,U
	STD -1,U
	LDA #$eb
	STD -41,U
	LDD #$bbbe
	STD -81,U
	LDB #$bb
	STD -121,U
	LEAU -280,U

	STD 119,U
	LDA #$ee
	STD 79,U
	LDA #$2e
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

	LDD #$bbeb
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	LDB #$ee
	STD -121,U
	LDD #$ebeb
	STD 119,U
	STD 79,U
	LEAU -280,U

	LDB #$ee
	STD 79,U
	STD 39,U
	LDB #$eb
	STD -1,U
	LDD #$bbee
	STD 119,U
	LDD #$eeeb
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U
	RTS

