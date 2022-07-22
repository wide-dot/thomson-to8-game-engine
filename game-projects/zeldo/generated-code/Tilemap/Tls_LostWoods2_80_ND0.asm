	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_80
	LEAU 481,U

	LDD #$eb5b
	STD 39,U
	STD -1,U
	LDA #$bb
	STD 79,U
	STD -41,U
	STD -81,U
	STD -121,U
	LDA #$be
	STD 119,U
	LEAU -280,U

	LDD #$55bb
	STD 119,U
	STD -1,U
	LDA #$5b
	STD 79,U
	LDD #$bbb5
	STD 39,U
	LDB #$0e
	STD -81,U
	LDB #$e5
	STD -41,U
	LDB #$22
	STD -121,U
	LEAU -201,U

	LDA #$be
	STD 40,U
	LDD #$e0dd
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$5b0d
	STD -81,U
	STD -121,U
	LDB #$ed
	STD -41,U
	LDB #$b5
	STD 119,U
	STD 79,U
	LDB #$be
	STD 39,U
	LDB #$bd
	STD -1,U
	LEAU -280,U

	LDD #$b5e1
	STD 119,U
	LDA #$55
	STD 79,U
	LDD #$5bb0
	STD 39,U
	LDD #$e0e1
	STD -81,U
	LDD #$be50
	STD -41,U
	LDA #$b5
	STD -1,U
	LDD #$0222
	STD -121,U
	LEAU -201,U

	LDD #$22dd
	STD 40,U
	STD ,U
	RTS

