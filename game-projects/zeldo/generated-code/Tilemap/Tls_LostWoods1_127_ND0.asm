	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_127
	LEAU 481,U

	LDD #$ebbb
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LDD #$bbb4
	STD 119,U
	STD 79,U
	LEAU -280,U

	LDD #$ebbb
	STD 119,U
	STD 79,U
	LDB #$ee
	STD 39,U
	LDD #$ee55
	STD -1,U
	LDD #$e544
	STD -41,U
	LDD #$e455
	STD -81,U
	LDD #$e5ee
	STD -121,U
	LEAU -201,U

	LDA #$ee
	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$4b4e
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	LDD #$bb4b
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -280,U

	STD 119,U
	LDB #$bb
	STD 79,U
	LDD #$eeeb
	STD 39,U
	LDD #$555e
	STD -1,U
	LDB #$54
	STD -81,U
	LDD #$4444
	STD -41,U
	LDD #$be4b
	STD -121,U
	LEAU -201,U

	LDD #$eeee
	STD 40,U
	STD ,U
	RTS

