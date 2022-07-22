	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_141
	LEAU 481,U

	LDD #$bb11
	STD 119,U
	STD -41,U
	LDA #$be
	STD 79,U
	LDB #$1e
	STD -121,U
	LDD #$4b11
	STD 39,U
	LDA #$44
	STD -1,U
	LDD #$ee1e
	STD -81,U
	LEAU -280,U

	LDD #$beee
	STD 119,U
	LDA #$ee
	STD 79,U
	STD 39,U
	LDA #$00
	STD -41,U
	STD -81,U
	STD -121,U
	LDA #$0e
	STD -1,U
	LEAU -201,U

	LDA #$00
	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$11ee
	STD 119,U
	LDD #$e1bb
	STD 39,U
	LDB #$b4
	STD -1,U
	LDB #$eb
	STD 79,U
	STD -41,U
	LDB #$ee
	STD -81,U
	LDA #$ee
	STD -121,U
	LEAU -280,U

	LDB #$eb
	STD 119,U
	LDB #$ee
	STD 79,U
	STD 39,U
	STD -1,U
	LDB #$e0
	STD -41,U
	LDB #$00
	STD -81,U
	LDA #$0e
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U
	RTS

