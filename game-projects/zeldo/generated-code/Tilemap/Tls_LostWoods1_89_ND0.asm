	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_89
	LEAU 481,U

	LDD #$0411
	STD 119,U
	LDA #$2e
	STD 79,U
	STD -41,U
	LDA #$d0
	STD 39,U
	STD -1,U
	LDA #$2b
	STD -81,U
	STD -121,U
	LEAU -280,U

	LDD #$dde0
	STD -121,U
	LDD #$2b11
	STD 79,U
	LDA #$de
	STD 39,U
	LDA #$dd
	STD -1,U
	LDB #$01
	STD -41,U
	LDB #$00
	STD -81,U
	LDD #$2411
	STD 119,U
	LEAU -201,U

	LDD #$ddde
	STD 40,U
	LDB #$dd
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$0010
	STD 119,U
	STD 79,U
	LDD #$0100
	STD 39,U
	STD -1,U
	STD -41,U
	LDB #$01
	STD -81,U
	STD -121,U
	LEAU -280,U

	LDB #$00
	STD 119,U
	LDA #$e1
	STD 79,U
	LDD #$e010
	STD 39,U
	STD -1,U
	LDD #$dd01
	STD -121,U
	LDD #$de11
	STD -81,U
	LDA #$d0
	STD -41,U
	LEAU -201,U

	LDD #$dd00
	STD 40,U
	LDB #$ee
	STD ,U
	RTS

