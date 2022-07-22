	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_88
	LEAU 481,U

	LDD #$dd99
	STD -41,U
	LDD #$d8e8
	STD 79,U
	LDD #$de79
	STD -1,U
	LDD #$d898
	STD 119,U
	LDB #$97
	STD 39,U
	LDD #$ddee
	STD -81,U
	LDB #$dd
	STD -121,U
	LEAU -280,U

	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$799e
	STD 119,U
	STD 79,U
	LDA #$98
	STD 39,U
	LDD #$978d
	STD -1,U
	LDD #$89ed
	STD -41,U
	LDD #$eedd
	STD -81,U
	LDA #$dd
	STD -121,U
	LEAU -280,U

	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U
	RTS

