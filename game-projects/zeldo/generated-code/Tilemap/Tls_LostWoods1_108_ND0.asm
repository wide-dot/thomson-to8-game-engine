	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_108
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	STD 79,U
	STD 39,U
	LDB #$d1
	STD -1,U
	LDB #$00
	STD -81,U
	STD -121,U
	LDB #$11
	STD -41,U
	LEAU -280,U

	LDD #$000e
	STD 79,U
	LDA #$d1
	STD 119,U
	LDA #$e0
	STD 39,U
	LDD #$eeeb
	STD -1,U
	STD -41,U
	LDA #$eb
	STD -81,U
	STD -121,U
	LEAU -201,U

	LDD #$b4be
	STD ,U
	LDA #$eb
	STD 40,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$ddde
	STD 119,U
	LDB #$1e
	STD 79,U
	LDD #$10b4
	STD -121,U
	LDA #$d1
	STD -81,U
	LDD #$ddeb
	STD 39,U
	STD -1,U
	LDB #$e4
	STD -41,U
	LEAU -280,U

	LDD #$00b4
	STD 119,U
	STD 79,U
	LDB #$be
	STD -1,U
	LDB #$eb
	STD 39,U
	LDD #$beb4
	STD -121,U
	LDD #$ee44
	STD -81,U
	LDD #$e0bb
	STD -41,U
	LEAU -201,U

	LDA #$bb
	STD ,U
	LDA #$be
	STD 40,U
	RTS

