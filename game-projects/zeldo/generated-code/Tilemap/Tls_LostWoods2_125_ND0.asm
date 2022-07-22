	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_125
	LEAU 481,U

	LDD #$e4dd
	STD -41,U
	STD -81,U
	STD -121,U
	LDA #$2e
	STD 79,U
	LDA #$eb
	STD 39,U
	STD -1,U
	LDA #$22
	STD 119,U
	LEAU -280,U

	LDA #$ee
	STD 119,U
	LDA #$e4
	STD 79,U
	STD -41,U
	STD -81,U
	LDA #$eb
	STD 39,U
	STD -1,U
	STD -121,U
	LEAU -201,U

	LDA #$de
	STD ,U
	LDA #$db
	STD 40,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$22dd
	STD 119,U
	LDA #$ee
	STD 79,U
	LDA #$be
	STD 39,U
	LDA #$bb
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -280,U

	LDA #$eb
	STD 119,U
	LDA #$4e
	STD 79,U
	LDA #$b4
	STD 39,U
	LDA #$bb
	STD -41,U
	STD -81,U
	LDA #$4b
	STD -1,U
	STD -121,U
	LEAU -201,U

	LDA #$be
	STD 40,U
	LDA #$ed
	STD ,U
	RTS

