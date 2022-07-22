	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_55
	LEAU 481,U

	LDD #$5bdd
	STD -1,U
	STD -41,U
	LDA #$ee
	STD 79,U
	LDA #$be
	STD 39,U
	LDA #$e1
	STD 119,U
	LDD #$551d
	STD -81,U
	LDD #$b501
	STD -121,U
	LEAU -280,U

	LDD #$bb00
	STD 119,U
	STD 39,U
	STD -41,U
	LDA #$5b
	STD 79,U
	LDD #$55ee
	STD -81,U
	STD -121,U
	LDD #$ee00
	STD -1,U
	LEAU -201,U

	LDD #$bbbe
	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$1ddd
	STD 39,U
	STD -1,U
	LDA #$dd
	STD 119,U
	STD 79,U
	LDA #$e1
	STD -41,U
	STD -81,U
	LDD #$e01d
	STD -121,U
	LEAU -280,U

	LDB #$01
	STD 119,U
	LDB #$00
	STD 79,U
	LDD #$beee
	STD -41,U
	LDB #$00
	STD 39,U
	LDB #$0e
	STD -1,U
	LDB #$be
	STD -81,U
	LDB #$bb
	STD -121,U
	LEAU -201,U

	LDA #$eb
	STD ,U
	LDA #$be
	STD 40,U
	RTS

