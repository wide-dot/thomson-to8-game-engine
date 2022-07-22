	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_202
	LEAU 481,U

	LDD #$bbdd
	STD 119,U
	STD 39,U
	LDA #$b5
	STD 79,U
	LDA #$dd
	STD -121,U
	LDA #$db
	STD -81,U
	LDA #$d5
	STD -1,U
	STD -41,U
	LEAU -280,U

	LDB #$db
	STD -1,U
	LDB #$d5
	STD -41,U
	STD -81,U
	LDD #$dbdd
	STD 39,U
	LDA #$dd
	STD 119,U
	STD 79,U
	LDD #$bbbb
	STD -121,U
	LEAU -201,U

	LDA #$dd
	STD ,U
	LDD #$bbb5
	STD 40,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$5bdd
	STD 39,U
	STD -1,U
	STD -81,U
	LDA #$5d
	STD 79,U
	LDA #$bd
	STD 119,U
	LDA #$bb
	STD -41,U
	STD -121,U
	LEAU -280,U

	LDA #$dd
	STD 119,U
	LDA #$bb
	STD 79,U
	LDD #$55bb
	STD 39,U
	LDD #$5b5b
	STD -1,U
	STD -81,U
	LDD #$bbbb
	STD -41,U
	LDD #$bd5b
	STD -121,U
	LEAU -201,U

	LDD #$ddbd
	STD ,U
	LDB #$5d
	STD 40,U
	RTS

