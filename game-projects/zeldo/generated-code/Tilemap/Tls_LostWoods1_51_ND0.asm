	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_51
	LEAU 481,U

	LDD #$bb01
	STD 119,U
	STD 79,U
	LDB #$00
	STD 39,U
	LDD #$ebe0
	STD -121,U
	LDA #$be
	STD -81,U
	LDA #$4e
	STD -1,U
	STD -41,U
	LEAU -280,U

	LDD #$e00e
	STD 79,U
	LDD #$eeee
	STD 119,U
	LDD #$000e
	STD 39,U
	LDB #$00
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -201,U

	LDB #$11
	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$e011
	STD 119,U
	LDA #$be
	STD 79,U
	STD 39,U
	LDA #$bb
	STD -1,U
	LDD #$ee01
	STD -121,U
	LDA #$bb
	STD -81,U
	LDD #$4b11
	STD -41,U
	LEAU -280,U

	LDD #$00e0
	STD 39,U
	LDB #$ee
	STD -1,U
	LDB #$00
	STD 79,U
	LDB #$0e
	STD -41,U
	LDB #$00
	STD -81,U
	STD -121,U
	LDA #$ee
	STD 119,U
	LEAU -201,U

	LDD #$1110
	STD ,U
	LDD #$0100
	STD 40,U
	RTS

