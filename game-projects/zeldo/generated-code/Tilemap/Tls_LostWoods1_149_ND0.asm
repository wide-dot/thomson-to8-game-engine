	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_149
	LEAU 481,U

	LDD #$bb44
	STD 79,U
	LDA #$4b
	STD 119,U
	LDB #$4b
	STD -81,U
	LDD #$b4bb
	STD 39,U
	STD -1,U
	LDD #$4bb4
	STD -41,U
	LDD #$4444
	STD -121,U
	LEAU -280,U

	STD 119,U
	STD 79,U
	STD 39,U
	LDA #$b4
	STD -81,U
	LDD #$bb4b
	STD -1,U
	LDB #$44
	STD -41,U
	LDA #$4b
	STD -121,U
	LEAU -201,U

	LDA #$44
	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$bb44
	STD 119,U
	LDB #$4b
	STD 79,U
	LDD #$4444
	STD -121,U
	LDD #$4bb4
	STD -1,U
	STD -41,U
	LDD #$b444
	STD -81,U
	LDD #$bbb4
	STD 39,U
	LEAU -280,U

	LDD #$b4bb
	STD -41,U
	LDD #$4b44
	STD 39,U
	LDA #$b4
	STD -1,U
	LDB #$4b
	STD -81,U
	LDD #$4444
	STD 119,U
	STD 79,U
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U
	RTS

