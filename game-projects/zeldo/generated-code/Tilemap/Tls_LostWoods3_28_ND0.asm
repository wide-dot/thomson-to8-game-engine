	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods3_28
	LEAU 481,U

	LDD #$11ee
	STD 39,U
	STD -1,U
	LDB #$ed
	STD -41,U
	STD -81,U
	LDB #$0e
	STD 79,U
	LDD #$0100
	STD 119,U
	LDD #$10dd
	STD -121,U
	LEAU -280,U

	LDA #$00
	STD 119,U
	STD 79,U
	STD 39,U
	LDA #$dd
	STD -81,U
	STD -121,U
	LDA #$ee
	STD -1,U
	STD -41,U
	LEAU -201,U

	LDA #$dd
	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$11ed
	STD 119,U
	LDA #$10
	STD 79,U
	LDD #$0edd
	STD -81,U
	STD -121,U
	LDA #$00
	STD -1,U
	STD -41,U
	LDA #$10
	STD 39,U
	LEAU -280,U

	LDA #$ed
	STD 39,U
	STD -1,U
	LDA #$ee
	STD 79,U
	LDA #$0e
	STD 119,U
	LDA #$dd
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U
	RTS

