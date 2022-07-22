	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_197
	LEAU 481,U

	LDD #$1022
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -280,U

	STD 119,U
	LDD #$0ebe
	STD -121,U
	LDD #$1001
	STD 39,U
	LDD #$0000
	STD -1,U
	LDB #$e0
	STD -41,U
	LDB #$ee
	STD -81,U
	LDD #$1011
	STD 79,U
	LEAU -201,U

	LDD #$beeb
	STD ,U
	LDD #$eebb
	STD 40,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$ee22
	STD 119,U
	LDA #$0e
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -280,U

	LDD #$ee12
	STD -1,U
	STD -41,U
	LDD #$0e22
	STD 119,U
	STD 79,U
	STD 39,U
	LDD #$eb12
	STD -81,U
	LDD #$bb02
	STD -121,U
	LEAU -201,U

	LDB #$01
	STD ,U
	LDA #$be
	STD 40,U
	RTS

