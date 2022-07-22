	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods3_68
	LEAU 481,U

	LDD #$661d
	STD -81,U
	LDD #$eedd
	STD 79,U
	LDA #$4e
	STD 39,U
	LDA #$64
	STD -1,U
	STD -41,U
	LDA #$e1
	STD 119,U
	LDD #$6601
	STD -121,U
	LEAU -280,U

	LDD #$6400
	STD 119,U
	STD 79,U
	LDA #$44
	STD 39,U
	STD -41,U
	LDA #$ee
	STD -1,U
	LDD #$66ee
	STD -81,U
	STD -121,U
	LEAU -201,U

	LDD #$444e
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
	LDD #$4eee
	STD -41,U
	LDB #$00
	STD 39,U
	LDB #$0e
	STD -1,U
	LDB #$4e
	STD -81,U
	LDB #$44
	STD -121,U
	LEAU -201,U

	LDA #$e4
	STD ,U
	LDA #$4e
	STD 40,U
	RTS

