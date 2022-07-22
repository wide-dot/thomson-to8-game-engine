	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_98
	LEAU 481,U

	LDD #$00dd
	STD 119,U
	LDA #$dd
	STD -121,U
	LDA #$ee
	STD 39,U
	STD -1,U
	LDA #$ed
	STD -41,U
	STD -81,U
	LDA #$0e
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

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$dddd
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LDA #$ed
	STD 119,U
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

