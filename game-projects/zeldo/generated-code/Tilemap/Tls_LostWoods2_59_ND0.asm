	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_59
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -280,U

	STD 119,U
	LDA #$ee
	STD 79,U
	LDA #$eb
	STD 39,U
	STD -1,U
	LDA #$b5
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -201,U

	LDA #$bb
	STD 40,U
	LDA #$eb
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -280,U

	STD 119,U
	LDA #$be
	STD 39,U
	LDA #$ee
	STD 79,U
	LDA #$55
	STD -1,U
	LDA #$5b
	STD -41,U
	LDA #$bb
	STD -81,U
	STD -121,U
	LEAU -201,U

	LDA #$5e
	STD 40,U
	LDA #$b0
	STD ,U
	RTS

