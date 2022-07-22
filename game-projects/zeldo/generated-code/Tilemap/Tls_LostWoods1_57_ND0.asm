	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_57
	LEAU 481,U

	LDD #$eeee
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LDB #$be
	STD 79,U
	LDD #$bb4b
	STD 119,U
	LEAU -280,U

	LDD #$eeee
	STD 119,U
	STD 79,U
	STD 39,U
	LDD #$e455
	STD -41,U
	LDB #$ee
	STD -1,U
	LDD #$e544
	STD -81,U
	LDD #$ee55
	STD -121,U
	LEAU -201,U

	LDD #$ebbb
	STD ,U
	LDB #$ee
	STD 40,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$ebbb
	STD 119,U
	LDD #$eeee
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LDA #$eb
	STD 79,U
	LEAU -280,U

	LDD #$5544
	STD -41,U
	LDD #$be54
	STD -1,U
	LDD #$eeee
	STD 119,U
	STD 79,U
	STD 39,U
	LDD #$4445
	STD -81,U
	LDD #$555e
	STD -121,U
	LEAU -201,U

	LDD #$bbbb
	STD ,U
	LDD #$eeeb
	STD 40,U
	RTS

