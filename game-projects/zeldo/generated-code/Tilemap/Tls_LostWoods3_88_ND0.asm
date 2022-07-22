	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods3_88
	LEAU 481,U

	LDD #$dd23
	STD -121,U
	LDB #$dd
	STD 119,U
	STD 79,U
	STD 39,U
	LDB #$d2
	STD -1,U
	LDB #$de
	STD -41,U
	STD -81,U
	LEAU -280,U

	LDD #$de33
	STD -81,U
	STD -121,U
	LDD #$dd43
	STD 79,U
	LDB #$33
	STD 39,U
	STD -1,U
	LDA #$d2
	STD -41,U
	LDD #$dd23
	STD 119,U
	LEAU -201,U

	LDD #$2343
	STD ,U
	LDB #$33
	STD 40,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$dd2e
	STD 79,U
	LDB #$d2
	STD 119,U
	LDB #$e3
	STD 39,U
	STD -1,U
	LDB #$33
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -280,U

	LDD #$e344
	STD -1,U
	LDB #$43
	STD -41,U
	LDD #$d234
	STD 79,U
	LDA #$2e
	STD 39,U
	LDD #$dd33
	STD 119,U
	LDD #$3343
	STD -81,U
	LDB #$44
	STD -121,U
	LEAU -201,U

	STD 40,U
	LDB #$45
	STD ,U
	RTS

