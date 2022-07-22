	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_167
	LEAU 481,U

	LDD #$de54
	STD 119,U
	LDD #$1ee4
	STD -1,U
	LDB #$b5
	STD 39,U
	LDB #$55
	STD 79,U
	LDD #$202e
	STD -41,U
	LDD #$d222
	STD -81,U
	LDA #$dd
	STD -121,U
	LEAU -280,U

	LDB #$dd
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LDB #$22
	STD 119,U
	LEAU -201,U

	LDB #$dd
	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$bb54
	STD 119,U
	LDD #$d20b
	STD -121,U
	LDD #$4544
	STD 39,U
	LDD #$4455
	STD -1,U
	LDD #$eebb
	STD -41,U
	LDD #$22e5
	STD -81,U
	LDD #$4b45
	STD 79,U
	LEAU -280,U

	LDD #$dddd
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LDB #$2e
	STD 119,U
	LEAU -201,U

	LDB #$dd
	STD 40,U
	STD ,U
	RTS

