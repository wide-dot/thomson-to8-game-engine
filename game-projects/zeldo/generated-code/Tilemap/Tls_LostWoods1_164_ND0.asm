	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_164
	LEAU 481,U

	LDD #$dbdd
	STD 79,U
	LDA #$dd
	STD 119,U
	LDA #$d5
	STD 39,U
	STD -1,U
	STD -41,U
	LDA #$bb
	STD -81,U
	STD -121,U
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

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$dddd
	STD -121,U
	LDA #$55
	STD 79,U
	LDA #$5b
	STD 39,U
	STD -41,U
	LDA #$bd
	STD -81,U
	LDA #$bb
	STD 119,U
	STD -1,U
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

