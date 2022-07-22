	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_186
	LEAU 481,U

	LDD #$dee4
	STD -81,U
	LDB #$b4
	STD -41,U
	LDB #$44
	STD 119,U
	STD 79,U
	LDB #$4b
	STD 39,U
	STD -1,U
	LDD #$ddbb
	STD -121,U
	LEAU -280,U

	LDB #$be
	STD 119,U
	LDB #$bb
	STD 79,U
	LDB #$b5
	STD 39,U
	LDB #$55
	STD -1,U
	LDB #$e5
	STD -41,U
	LDB #$de
	STD -81,U
	LDB #$dd
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$5bb4
	STD -41,U
	LDD #$eeee
	STD 39,U
	LDD #$be4b
	STD -1,U
	LDD #$5ebe
	STD 119,U
	STD 79,U
	LDD #$5b4b
	STD -81,U
	LDD #$5544
	STD -121,U
	LEAU -280,U

	LDB #$bb
	STD 119,U
	LDD #$e5ee
	STD 79,U
	LDD #$debb
	STD 39,U
	LDD #$dd55
	STD -1,U
	STD -41,U
	LDB #$ee
	STD -81,U
	LDB #$dd
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U
	RTS

