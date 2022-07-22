	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_154
	LEAU 481,U

	LDD #$2222
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	LDA #$11
	STD -41,U
	LDA #$00
	STD -81,U
	LDA #$ee
	STD -121,U
	LEAU -280,U

	LDA #$be
	STD 119,U
	LDB #$00
	STD 79,U
	STD 39,U
	LDD #$eeee
	STD -1,U
	LDA #$bb
	STD -41,U
	LDA #$44
	STD -81,U
	STD -121,U
	LEAU -201,U

	LDD #$bbbe
	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$0222
	STD -121,U
	LDA #$12
	STD -81,U
	LDA #$22
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	LEAU -280,U

	LDA #$e1
	STD 119,U
	LDD #$bebe
	STD -81,U
	LDB #$bb
	STD -121,U
	LDB #$00
	STD 39,U
	LDB #$ee
	STD -1,U
	STD -41,U
	LDD #$ee11
	STD 79,U
	LEAU -201,U

	LDD #$ebbb
	STD ,U
	LDA #$be
	STD 40,U
	RTS

