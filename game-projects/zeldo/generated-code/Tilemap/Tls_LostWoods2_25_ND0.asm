	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_25
	LEAU 481,U

	LDD #$11e5
	STD 39,U
	STD -1,U
	LDB #$0e
	STD 79,U
	LDA #$01
	STD 119,U
	LDD #$11bb
	STD -41,U
	STD -81,U
	LDD #$10ee
	STD -121,U
	LEAU -280,U

	LDA #$00
	STD 119,U
	LDD #$e000
	STD -41,U
	LDA #$0e
	STD 39,U
	LDA #$ee
	STD -1,U
	LDA #$00
	STD 79,U
	STD -81,U
	STD -121,U
	LEAU -201,U

	LDB #$11
	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$0ebe
	STD -81,U
	STD -121,U
	LDD #$10e5
	STD 79,U
	STD 39,U
	LDD #$00b5
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

	LDA #$01
	STD 40,U
	LDD #$1110
	STD ,U
	RTS

