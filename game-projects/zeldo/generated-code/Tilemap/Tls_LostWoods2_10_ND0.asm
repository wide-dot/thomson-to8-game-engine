	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_10
	LEAU 481,U

	LDD #$ebb4
	STD -81,U
	LDD #$eebb
	STD 79,U
	STD 39,U
	LDB #$b4
	STD -1,U
	STD -41,U
	LDD #$bebb
	STD 119,U
	LDD #$eb44
	STD -121,U
	LEAU -280,U

	STD 119,U
	LDD #$bb4b
	STD 79,U
	LDD #$b4ee
	STD -81,U
	STD -121,U
	LDB #$bb
	STD -1,U
	LDB #$be
	STD -41,U
	LDD #$bbbb
	STD 39,U
	LEAU -201,U

	LDA #$4b
	STD ,U
	LDD #$44ee
	STD 40,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$ebb4
	STD 119,U
	LDD #$b4bb
	STD -121,U
	LDD #$bb4b
	STD -41,U
	LDB #$bb
	STD -81,U
	LDD #$eb44
	STD 79,U
	STD 39,U
	LDB #$4b
	STD -1,U
	LEAU -280,U

	LDD #$44be
	STD 119,U
	STD 79,U
	LDA #$4b
	STD 39,U
	LDD #$beeb
	STD -121,U
	LDD #$bbee
	STD -41,U
	LDB #$eb
	STD -81,U
	LDD #$4bee
	STD -1,U
	LEAU -201,U

	LDD #$eeb4
	STD ,U
	LDD #$bebb
	STD 40,U
	RTS

