	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_54
	LEAU 481,U

	LDD #$dd00
	STD -81,U
	STD -121,U
	LDB #$11
	STD -41,U
	LDB #$dd
	STD 119,U
	STD 79,U
	STD 39,U
	LDB #$d1
	STD -1,U
	LEAU -280,U

	LDD #$eeeb
	STD -1,U
	STD -41,U
	LDD #$000e
	STD 79,U
	LDA #$e0
	STD 39,U
	LDA #$d1
	STD 119,U
	LDD #$ebeb
	STD -81,U
	STD -121,U
	LEAU -201,U

	LDB #$be
	STD 40,U
	LDA #$b5
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$ddde
	STD 119,U
	LDB #$1e
	STD 79,U
	LDB #$eb
	STD 39,U
	STD -1,U
	LDB #$e5
	STD -41,U
	LDD #$d1b5
	STD -81,U
	LDA #$10
	STD -121,U
	LEAU -280,U

	LDA #$00
	STD 119,U
	STD 79,U
	LDB #$be
	STD -1,U
	LDB #$eb
	STD 39,U
	LDD #$e0bb
	STD -41,U
	LDD #$ee55
	STD -81,U
	LDD #$beb5
	STD -121,U
	LEAU -201,U

	LDB #$bb
	STD 40,U
	LDA #$bb
	STD ,U
	RTS

