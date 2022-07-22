	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_71
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

	LDD #$10b4
	STD -41,U
	LDD #$dd22
	STD 79,U
	LDD #$d12e
	STD 39,U
	LDB #$eb
	STD -1,U
	LDD #$dddd
	STD 119,U
	LDD #$1e44
	STD -81,U
	LDB #$4e
	STD -121,U
	LEAU -201,U

	LDD #$0beb
	STD ,U
	LDA #$1e
	STD 40,U

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
	LDD #$d22e
	STD 79,U
	LDA #$12
	STD 39,U
	LDD #$0224
	STD -1,U
	LDD #$bbbb
	STD -121,U
	LDD #$e4eb
	STD -81,U
	LDD #$eeee
	STD -41,U
	LEAU -201,U

	LDD #$4e4b
	STD 40,U
	LDD #$444e
	STD ,U
	RTS

