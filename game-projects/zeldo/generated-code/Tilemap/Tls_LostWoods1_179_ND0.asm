	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_179
	LEAU 481,U

	LDD #$ddbe
	STD 119,U
	LDD #$d000
	STD -1,U
	LDD #$d1e0
	STD 39,U
	LDD #$ddee
	STD 79,U
	LDD #$1e00
	STD -41,U
	LDA #$eb
	STD -81,U
	LDD #$e401
	STD -121,U
	LEAU -280,U

	LDD #$2b11
	STD -121,U
	LDA #$04
	STD 79,U
	LDA #$2e
	STD 39,U
	STD -81,U
	LDA #$d0
	STD -1,U
	STD -41,U
	LDA #$e4
	STD 119,U
	LEAU -201,U

	LDA #$2b
	STD 40,U
	LDA #$24
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$bbee
	STD 119,U
	LDD #$e011
	STD -41,U
	STD -81,U
	STD -121,U
	LDD #$ee00
	STD 79,U
	STD 39,U
	LDB #$01
	STD -1,U
	LEAU -280,U

	LDD #$e011
	STD 119,U
	LDD #$0010
	STD 79,U
	STD 39,U
	LDD #$0100
	STD -1,U
	STD -41,U
	STD -81,U
	LDB #$01
	STD -121,U
	LEAU -201,U

	STD 40,U
	LDB #$00
	STD ,U
	RTS

