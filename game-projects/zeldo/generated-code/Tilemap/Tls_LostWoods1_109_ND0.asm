	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_109
	LEAU 481,U

	LDD #$e1dd
	STD 119,U
	LDA #$be
	STD 39,U
	LDA #$ee
	STD 79,U
	LDA #$4b
	STD -1,U
	STD -41,U
	LDD #$441d
	STD -81,U
	LDD #$5401
	STD -121,U
	LEAU -280,U

	LDD #$ee00
	STD -1,U
	LDA #$4b
	STD 79,U
	LDA #$bb
	STD 39,U
	STD -41,U
	LDA #$5b
	STD 119,U
	LDD #$44ee
	STD -81,U
	STD -121,U
	LEAU -201,U

	LDD #$bbbe
	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	STD 79,U
	LDD #$e01d
	STD -121,U
	LDD #$e1dd
	STD -41,U
	STD -81,U
	LDA #$1d
	STD 39,U
	STD -1,U
	LEAU -280,U

	LDD #$e001
	STD 119,U
	LDB #$00
	STD 79,U
	LDD #$beee
	STD -41,U
	LDB #$00
	STD 39,U
	LDB #$0e
	STD -1,U
	LDB #$be
	STD -81,U
	LDB #$bb
	STD -121,U
	LEAU -201,U

	STD 40,U
	LDA #$eb
	STD ,U
	RTS

