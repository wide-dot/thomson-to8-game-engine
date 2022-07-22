	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods3_5
	LEAU 481,U

	LDD #$441d
	STD 119,U
	LDA #$4e
	STD 79,U
	LDD #$640d
	STD 39,U
	LDA #$66
	STD -1,U
	LDD #$4401
	STD -41,U
	LDA #$ee
	STD -81,U
	LDA #$4e
	STD -121,U
	LEAU -280,U

	LDB #$e1
	STD 119,U
	LDD #$ee44
	STD 39,U
	LDB #$ee
	STD 79,U
	LDD #$0e66
	STD -1,U
	LDA #$00
	STD -41,U
	STD -81,U
	LDB #$6e
	STD -121,U
	LEAU -201,U

	LDB #$61
	STD 40,U
	LDB #$e1
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$e0dd
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -280,U

	LDD #$ee0d
	STD 39,U
	LDB #$dd
	STD 119,U
	STD 79,U
	STD -81,U
	LDB #$ed
	STD -1,U
	STD -41,U
	LDD #$0edd
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U
	RTS

