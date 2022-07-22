	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods3_146
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	LDA #$1d
	STD -81,U
	LDA #$01
	STD -121,U
	LEAU -280,U

	LDA #$00
	STD 119,U
	LDB #$ee
	STD 79,U
	LDB #$e4
	STD 39,U
	STD -1,U
	LDB #$46
	STD -41,U
	LDA #$ee
	STD -81,U
	STD -121,U
	LEAU -201,U

	LDD #$4ee4
	STD ,U
	LDB #$44
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
	LDA #$1d
	STD -121,U
	LEAU -280,U

	LDA #$01
	STD 119,U
	LDD #$00ee
	STD 79,U
	LDB #$4e
	STD 39,U
	LDD #$0e66
	STD -1,U
	LDD #$4464
	STD -121,U
	LDD #$4e66
	STD -81,U
	LDA #$ee
	STD -41,U
	LEAU -201,U

	LDD #$4440
	STD ,U
	LDB #$6e
	STD 40,U
	RTS

