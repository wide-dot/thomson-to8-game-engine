	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_200
	LEAU 481,U

	LDD #$2211
	STD 119,U
	LDD #$2100
	STD 79,U
	LDD #$ebbb
	STD -121,U
	LDD #$10ee
	STD -1,U
	LDD #$0ebe
	STD -41,U
	LDB #$4e
	STD -81,U
	LDD #$21e0
	STD 39,U
	LEAU -280,U

	LDD #$ebee
	STD 119,U
	LDD #$ee00
	STD 39,U
	LDD #$beee
	STD 79,U
	LDD #$e000
	STD -1,U
	LDD #$0010
	STD -41,U
	LDB #$11
	STD -81,U
	STD -121,U
	LEAU -201,U

	LDA #$11
	STD ,U
	LDA #$01
	STD 40,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$1112
	STD 119,U
	LDA #$00
	STD 79,U
	LDD #$bebe
	STD -121,U
	LDD #$ee01
	STD -1,U
	LDB #$e0
	STD -41,U
	LDD #$bbbe
	STD -81,U
	LDD #$0e01
	STD 39,U
	LEAU -280,U

	LDD #$eebe
	STD 119,U
	LDB #$ee
	STD 79,U
	LDD #$000e
	STD 39,U
	LDB #$00
	STD -1,U
	LDA #$01
	STD -41,U
	LDA #$11
	STD -81,U
	LDB #$10
	STD -121,U
	LEAU -201,U

	STD 40,U
	LDB #$11
	STD ,U
	RTS

