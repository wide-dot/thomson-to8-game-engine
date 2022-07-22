	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_161
	LEAU 481,U

	LDD #$eedd
	STD 39,U
	STD -1,U
	LDA #$11
	STD 79,U
	LDA #$dd
	STD 119,U
	LDA #$be
	STD -41,U
	STD -81,U
	LDA #$e4
	STD -121,U
	LEAU -280,U

	LDA #$eb
	STD 119,U
	LDD #$11be
	STD -41,U
	LDD #$12e1
	STD 39,U
	LDD #$114e
	STD -1,U
	LDD #$2e1d
	STD 79,U
	LDD #$11ee
	STD -81,U
	STD -121,U
	LEAU -201,U

	LDB #$2e
	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	STD 79,U
	LDA #$1d
	STD 39,U
	LDA #$4e
	STD -121,U
	LDA #$e1
	STD -41,U
	LDA #$be
	STD -81,U
	LDA #$ed
	STD -1,U
	LEAU -280,U

	LDA #$4e
	STD 119,U
	LDD #$111d
	STD -81,U
	STD -121,U
	LDD #$2edd
	STD 39,U
	LDA #$1e
	STD -1,U
	LDA #$12
	STD -41,U
	LDA #$ee
	STD 79,U
	LEAU -201,U

	LDD #$111d
	STD 40,U
	STD ,U
	RTS

