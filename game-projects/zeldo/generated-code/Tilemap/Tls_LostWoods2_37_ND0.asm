	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_37
	LEAU 481,U

	LDD #$be4e
	STD 119,U
	LDA #$ee
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	LDD #$ebbe
	STD -81,U
	LDB #$bb
	STD -121,U
	LEAU -280,U

	STD 119,U
	LDD #$bbbe
	STD 79,U
	STD 39,U
	LDA #$b4
	STD -1,U
	LDB #$ee
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -201,U

	LDD #$4beb
	STD ,U
	LDA #$44
	STD 40,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$ebeb
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	LDD #$b4ee
	STD -121,U
	LDD #$bbeb
	STD -41,U
	STD -81,U
	LEAU -280,U

	STD -41,U
	STD -81,U
	LDA #$4b
	STD 39,U
	STD -1,U
	LDD #$44ee
	STD 119,U
	LDB #$eb
	STD 79,U
	LDD #$beee
	STD -121,U
	LEAU -201,U

	LDB #$be
	STD 40,U
	LDD #$eebb
	STD ,U
	RTS

