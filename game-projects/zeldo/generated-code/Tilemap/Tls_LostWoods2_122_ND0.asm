	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_122
	LEAU 481,U

	LDD #$bb55
	STD 119,U
	LDD #$eee5
	STD -121,U
	LDD #$eb55
	STD -1,U
	LDA #$ee
	STD -41,U
	LDB #$45
	STD -81,U
	LDD #$be55
	STD 79,U
	STD 39,U
	LEAU -280,U

	LDD #$eee4
	STD 119,U
	LDB #$eb
	STD -41,U
	LDB #$ee
	STD -81,U
	STD -121,U
	LDD #$ebbe
	STD -1,U
	LDD #$bebb
	STD 79,U
	LDB #$be
	STD 39,U
	LEAU -201,U

	LDD #$eeee
	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$be55
	STD -41,U
	LDA #$45
	STD 79,U
	LDA #$eb
	STD 39,U
	STD -81,U
	STD -121,U
	LDA #$ee
	STD -1,U
	LDA #$55
	STD 119,U
	LEAU -280,U

	LDD #$bebe
	STD -81,U
	LDD #$ee45
	STD 39,U
	LDB #$eb
	STD -1,U
	LDB #$ee
	STD -41,U
	LDB #$eb
	STD -121,U
	LDB #$55
	STD 119,U
	STD 79,U
	LEAU -201,U

	LDB #$ee
	STD ,U
	LDD #$ebeb
	STD 40,U
	RTS

