	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_198
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	LDA #$bb
	STD -81,U
	STD -121,U
	LDA #$d5
	STD 39,U
	STD -1,U
	STD -41,U
	LDA #$db
	STD 79,U
	LEAU -280,U

	LDD #$ddbb
	STD 79,U
	LDB #$b5
	STD 39,U
	LDB #$bb
	STD -1,U
	LDB #$dd
	STD 119,U
	LDB #$d5
	STD -41,U
	STD -81,U
	LDB #$db
	STD -121,U
	LEAU -201,U

	LDB #$dd
	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$dddd
	STD -121,U
	LDA #$55
	STD 79,U
	LDA #$5b
	STD 39,U
	STD -41,U
	LDA #$bd
	STD -81,U
	LDA #$bb
	STD 119,U
	STD -1,U
	LEAU -280,U

	LDD #$ddbd
	STD 79,U
	LDB #$bb
	STD -81,U
	LDB #$dd
	STD 119,U
	LDB #$5d
	STD 39,U
	LDB #$5b
	STD -1,U
	STD -41,U
	STD -121,U
	LEAU -201,U

	LDB #$bb
	STD 40,U
	LDB #$dd
	STD ,U
	RTS

