	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_134
	LEAU 481,U

	LDD #$10dd
	STD -121,U
	LDD #$110e
	STD 79,U
	LDB #$ee
	STD 39,U
	STD -1,U
	LDB #$ed
	STD -41,U
	STD -81,U
	LDD #$0100
	STD 119,U
	LEAU -280,U

	LDD #$eedd
	STD -1,U
	STD -41,U
	LDA #$00
	STD 119,U
	STD 79,U
	STD 39,U
	LDA #$dd
	STD -81,U
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$10ed
	STD 79,U
	LDA #$11
	STD 119,U
	LDD #$10dd
	STD 39,U
	LDA #$00
	STD -1,U
	STD -41,U
	LDA #$0e
	STD -81,U
	STD -121,U
	LEAU -280,U

	STD 119,U
	LDA #$ee
	STD 79,U
	LDA #$ed
	STD 39,U
	STD -1,U
	LDA #$dd
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U
	RTS

