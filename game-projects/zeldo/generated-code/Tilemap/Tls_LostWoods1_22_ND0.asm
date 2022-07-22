	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_22
	LEAU 481,U

	LDD #$22e0
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -280,U

	STD 119,U
	LDA #$0e
	STD -1,U
	LDA #$00
	STD 39,U
	LDA #$11
	STD 79,U
	LDA #$ee
	STD -41,U
	LDD #$ebee
	STD -81,U
	STD -121,U
	LEAU -201,U

	LDD #$b4be
	STD ,U
	LDA #$eb
	STD 40,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$2200
	STD 119,U
	LDB #$01
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -280,U

	STD 119,U
	LDA #$10
	STD 79,U
	LDA #$00
	STD 39,U
	LDD #$be00
	STD -121,U
	LDD #$ee01
	STD -1,U
	LDB #$00
	STD -41,U
	STD -81,U
	LEAU -201,U

	LDD #$bbe0
	STD ,U
	LDD #$be00
	STD 40,U
	RTS

