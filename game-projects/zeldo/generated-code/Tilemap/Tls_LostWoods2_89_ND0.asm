	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_89
	LEAU 481,U

	LDD #$dee0
	STD -41,U
	STD -81,U
	LDB #$ee
	STD -121,U
	LDD #$d01d
	STD 39,U
	LDD #$de01
	STD -1,U
	LDD #$dddd
	STD 119,U
	STD 79,U
	LEAU -280,U

	LDB #$bb
	STD 119,U
	STD -1,U
	LDD #$00b5
	STD -121,U
	LDD #$d1eb
	STD -41,U
	LDD #$d0bb
	STD -81,U
	LDD #$dd5b
	STD 79,U
	LDB #$5e
	STD 39,U
	LEAU -201,U

	LDD #$0e5b
	STD 40,U
	LDA #$e5
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$ddd0
	STD 119,U
	LDB #$de
	STD 79,U
	LDD #$55eb
	STD -81,U
	LDD #$e00b
	STD -1,U
	LDD #$5eeb
	STD -41,U
	LDD #$111b
	STD 39,U
	LDD #$55bb
	STD -121,U
	LEAU -280,U

	LDD #$5bbe
	STD 119,U
	LDD #$ebbb
	STD 79,U
	LDA #$e5
	STD 39,U
	LDD #$05b5
	STD -1,U
	LDD #$ee5b
	STD -81,U
	LDD #$0eb5
	STD -41,U
	LDD #$be5b
	STD -121,U
	LEAU -201,U

	LDD #$bbb5
	STD 40,U
	STD ,U
	RTS

