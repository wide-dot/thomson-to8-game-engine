	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods3_17
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

	LDA #$46
	STD -41,U
	STD -81,U
	STD -121,U
	LDA #$ee
	STD 79,U
	LDA #$e4
	STD 39,U
	STD -1,U
	LDA #$dd
	STD 119,U
	LEAU -201,U

	LDA #$44
	STD 40,U
	LDA #$e4
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

	LDA #$4e
	STD 39,U
	LDA #$ee
	STD 79,U
	LDA #$dd
	STD 119,U
	LDA #$66
	STD -1,U
	STD -41,U
	STD -81,U
	LDA #$64
	STD -121,U
	LEAU -201,U

	LDA #$40
	STD ,U
	LDA #$6e
	STD 40,U
	RTS

