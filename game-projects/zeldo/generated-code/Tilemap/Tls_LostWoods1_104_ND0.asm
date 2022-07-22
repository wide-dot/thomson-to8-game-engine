	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_104
	LEAU 481,U

	LDD #$eddd
	STD 119,U
	LDA #$b0
	STD 79,U
	LDA #$4e
	STD 39,U
	LDD #$bb1d
	STD -1,U
	LDD #$4eb4
	STD -121,U
	LDD #$4bbb
	STD -81,U
	LDD #$ebee
	STD -41,U
	LEAU -280,U

	LDB #$b4
	STD 119,U
	LDD #$eeeb
	STD 79,U
	LDA #$00
	STD 39,U
	LDB #$ee
	STD -1,U
	LDD #$110e
	STD -81,U
	STD -121,U
	LDA #$10
	STD -41,U
	LEAU -201,U

	LDD #$1100
	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	LDA #$1d
	STD 79,U
	LDD #$eeed
	STD -81,U
	LDD #$e0dd
	STD -1,U
	LDA #$ee
	STD -41,U
	LDA #$01
	STD 39,U
	LDD #$beed
	STD -121,U
	LEAU -280,U

	STD 119,U
	LDA #$ee
	STD 79,U
	LDD #$00e1
	STD -41,U
	LDB #$ee
	STD -81,U
	LDB #$0d
	STD -1,U
	LDD #$0e1d
	STD 39,U
	LDD #$104b
	STD -121,U
	LEAU -201,U

	LDB #$bb
	STD 40,U
	LDD #$11eb
	STD ,U
	RTS

