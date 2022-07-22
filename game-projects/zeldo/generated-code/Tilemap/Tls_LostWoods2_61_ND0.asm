	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_61
	LEAU 481,U

	LDD #$eeee
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -280,U

	LDB #$eb
	STD 119,U
	STD 79,U
	LDD #$bbb4
	STD -81,U
	STD -121,U
	LDD #$eebb
	STD 39,U
	STD -1,U
	STD -41,U
	LEAU -201,U

	LDD #$b4b4
	STD 40,U
	LDB #$bb
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$eeeb
	STD 119,U
	STD 79,U
	LDB #$ee
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	LDB #$bb
	STD -121,U
	LEAU -280,U

	STD 119,U
	LDB #$b4
	STD 79,U
	LDB #$44
	STD 39,U
	STD -1,U
	LDA #$bb
	STD -81,U
	STD -121,U
	LDA #$eb
	STD -41,U
	LEAU -201,U

	LDD #$bb4b
	STD 40,U
	LDA #$4b
	STD ,U
	RTS

