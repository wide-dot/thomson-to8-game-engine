	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_19
	LEAU 481,U

	LDD #$10ee
	STD -121,U
	LDD #$110e
	STD 79,U
	LDB #$e4
	STD 39,U
	STD -1,U
	LDB #$bb
	STD -41,U
	STD -81,U
	LDD #$010e
	STD 119,U
	LEAU -280,U

	LDD #$00ee
	STD 119,U
	LDD #$0e00
	STD 39,U
	LDA #$00
	STD 79,U
	STD -81,U
	STD -121,U
	LDA #$ee
	STD -1,U
	LDA #$e0
	STD -41,U
	LEAU -201,U

	LDD #$0011
	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$0ebe
	STD -81,U
	STD -121,U
	LDD #$10e4
	STD 79,U
	STD 39,U
	LDD #$00b4
	STD -1,U
	LDB #$bb
	STD -41,U
	LDD #$11eb
	STD 119,U
	LEAU -280,U

	LDD #$0eee
	STD 119,U
	LDD #$ee0e
	STD 79,U
	LDD #$0000
	STD -41,U
	STD -81,U
	STD -121,U
	LDA #$e0
	STD 39,U
	STD -1,U
	LEAU -201,U

	LDD #$1110
	STD ,U
	LDD #$0100
	STD 40,U
	RTS

