	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_91
	LEAU 481,U

	LDD #$e555
	STD 119,U
	LDB #$54
	STD 79,U
	LDA #$d4
	STD 39,U
	LDA #$dd
	STD -41,U
	STD -81,U
	LDA #$de
	STD -1,U
	LDD #$d145
	STD -121,U
	LEAU -280,U

	LDD #$202e
	STD -81,U
	LDD #$de54
	STD 79,U
	LDD #$1e55
	STD 39,U
	LDB #$b5
	STD -1,U
	LDB #$e4
	STD -41,U
	LDD #$d045
	STD 119,U
	LDD #$d222
	STD -121,U
	LEAU -201,U

	LDA #$dd
	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$e45e
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	LDB #$bb
	STD 119,U
	LDB #$4b
	STD -81,U
	LDD #$e5b4
	STD -121,U
	LEAU -280,U

	STD 119,U
	LDD #$bb54
	STD 79,U
	LDD #$4b45
	STD 39,U
	LDD #$4544
	STD -1,U
	LDD #$4455
	STD -41,U
	LDD #$eebb
	STD -81,U
	LDD #$22e5
	STD -121,U
	LEAU -201,U

	LDD #$dd2e
	STD ,U
	LDD #$d20b
	STD 40,U
	RTS

