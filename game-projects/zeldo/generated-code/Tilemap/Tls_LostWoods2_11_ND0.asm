	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_11
	LEAU 481,U

	LDD #$5544
	STD 119,U
	LDB #$bb
	STD 79,U
	LDA #$bb
	STD 39,U
	LDA #$ee
	STD -81,U
	LDA #$be
	STD -41,U
	LDD #$bbee
	STD -1,U
	LDD #$ebbb
	STD -121,U
	LEAU -280,U

	LDB #$b4
	STD 119,U
	LDD #$b444
	STD 79,U
	STD 39,U
	LDB #$4b
	STD -1,U
	LDB #$44
	STD -41,U
	LDA #$44
	STD -81,U
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$ebeb
	STD -41,U
	LDD #$bb45
	STD 79,U
	LDB #$bb
	STD 39,U
	LDB #$be
	STD -81,U
	LDD #$eeeb
	STD -1,U
	LDD #$5455
	STD 119,U
	LDD #$4bbe
	STD -121,U
	LEAU -280,U

	LDD #$b444
	STD -81,U
	STD -121,U
	LDD #$444b
	STD 79,U
	STD 39,U
	STD -1,U
	LDB #$44
	STD -41,U
	LDB #$bb
	STD 119,U
	LEAU -201,U

	LDB #$44
	STD 40,U
	STD ,U
	RTS

