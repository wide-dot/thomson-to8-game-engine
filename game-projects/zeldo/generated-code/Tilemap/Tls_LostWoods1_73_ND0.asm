	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_73
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -280,U

	STD 119,U
	LDD #$2222
	STD 79,U
	LDD #$e2e2
	STD 39,U
	LDA #$4e
	STD -1,U
	LDD #$e442
	STD -41,U
	LDD #$4ebe
	STD -81,U
	LDB #$4e
	STD -121,U
	LEAU -201,U

	LDD #$be44
	STD 40,U
	LDB #$eb
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -280,U

	STD 119,U
	LDD #$2e1d
	STD 39,U
	LDD #$22dd
	STD 79,U
	LDD #$e401
	STD -1,U
	LDD #$4be1
	STD -41,U
	LDD #$e4e0
	STD -81,U
	LDD #$beee
	STD -121,U
	LEAU -201,U

	LDB #$be
	STD 40,U
	LDB #$4e
	STD ,U
	RTS

