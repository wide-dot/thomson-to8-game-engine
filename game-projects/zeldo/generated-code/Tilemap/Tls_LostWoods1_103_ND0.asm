	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_103
	LEAU 481,U

	LDD #$ddee
	STD -41,U
	STD -81,U
	LDB #$10
	STD -1,U
	LDB #$dd
	STD 119,U
	STD 79,U
	LDB #$d1
	STD 39,U
	LDB #$be
	STD -121,U
	LEAU -280,U

	LDB #$eb
	STD 119,U
	LDB #$ee
	STD 39,U
	LDB #$be
	STD 79,U
	LDD #$d1e0
	STD -1,U
	LDD #$d000
	STD -41,U
	LDA #$1e
	STD -81,U
	LDA #$eb
	STD -121,U
	LEAU -201,U

	LDD #$e401
	STD 40,U
	LDB #$11
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$ddd0
	STD 119,U
	LDB #$ee
	STD -1,U
	LDB #$0b
	STD 39,U
	LDB #$1e
	STD 79,U
	LDD #$eeeb
	STD -41,U
	LDA #$bb
	STD -81,U
	LDB #$bb
	STD -121,U
	LEAU -280,U

	LDD #$e011
	STD -81,U
	STD -121,U
	LDD #$bbee
	STD 79,U
	LDD #$ee00
	STD 39,U
	STD -1,U
	LDB #$01
	STD -41,U
	LDD #$b4be
	STD 119,U
	LEAU -201,U

	LDD #$e011
	STD 40,U
	STD ,U
	RTS

