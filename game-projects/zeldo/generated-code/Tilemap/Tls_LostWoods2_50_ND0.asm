	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_50
	LEAU 481,U

	LDD #$bb1d
	STD 119,U
	LDA #$be
	STD 79,U
	LDD #$5b0d
	STD 39,U
	LDA #$55
	STD -1,U
	LDD #$bb01
	STD -41,U
	LDA #$ee
	STD -81,U
	LDA #$be
	STD -121,U
	LEAU -280,U

	LDB #$e1
	STD 119,U
	LDD #$eeee
	STD 79,U
	LDB #$bb
	STD 39,U
	LDD #$0e55
	STD -1,U
	LDA #$00
	STD -41,U
	STD -81,U
	LDB #$be
	STD -121,U
	LEAU -201,U

	LDB #$e1
	STD ,U
	LDB #$51
	STD 40,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$e0dd
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -280,U

	LDA #$ee
	STD 119,U
	STD 79,U
	STD -81,U
	LDB #$ed
	STD -1,U
	STD -41,U
	LDB #$0d
	STD 39,U
	LDD #$0edd
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U
	RTS

