	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_101
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
	LDA #$b4
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
	LDA #$ee
	STD 79,U
	LDA #$be
	STD 39,U
	LDA #$44
	STD -1,U
	LDA #$55
	STD -81,U
	LDA #$45
	STD -41,U
	LDA #$5b
	STD -121,U
	LEAU -201,U

	LDA #$b0
	STD ,U
	LDA #$4e
	STD 40,U
	RTS

