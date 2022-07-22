	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_66
	LEAU 481,U

	LDD #$ee22
	STD 119,U
	LDB #$2e
	STD 79,U
	LDB #$ee
	STD 39,U
	LDD #$bbbb
	STD -81,U
	STD -121,U
	LDD #$ebee
	STD -1,U
	STD -41,U
	LEAU -280,U

	LDD #$4444
	STD -41,U
	STD -81,U
	STD -121,U
	LDD #$b4bb
	STD 39,U
	STD -1,U
	LDA #$bb
	STD 119,U
	STD 79,U
	LEAU -201,U

	LDD #$4454
	STD 40,U
	LDB #$55
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$bebe
	STD -1,U
	LDD #$eeee
	STD 79,U
	STD 39,U
	LDA #$e2
	STD 119,U
	LDD #$bbbb
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -280,U

	LDD #$b444
	STD -41,U
	LDD #$4b4b
	STD 39,U
	LDD #$4444
	STD -1,U
	LDD #$bbbb
	STD 119,U
	STD 79,U
	LDD #$44b4
	STD -81,U
	STD -121,U
	LEAU -201,U

	LDD #$5554
	STD ,U
	LDD #$4544
	STD 40,U
	RTS

