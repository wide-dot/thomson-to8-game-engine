	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_98
	LEAU 481,U

	LDD #$bbdd
	STD 119,U
	STD 39,U
	LDA #$b5
	STD 79,U
	LDA #$db
	STD -81,U
	LDA #$d5
	STD -1,U
	STD -41,U
	LDA #$dd
	STD -121,U
	LEAU -280,U

	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$bddd
	STD 119,U
	LDA #$bb
	STD -41,U
	STD -121,U
	LDA #$5b
	STD 39,U
	STD -1,U
	STD -81,U
	LDA #$5d
	STD 79,U
	LEAU -280,U

	LDA #$dd
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U
	RTS

