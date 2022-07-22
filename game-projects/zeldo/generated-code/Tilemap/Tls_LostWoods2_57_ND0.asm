	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_57
	LEAU 481,U

	LDD #$dde0
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -280,U

	LDA #$d1
	STD 119,U
	LDD #$ebee
	STD -81,U
	STD -121,U
	LDD #$e0e0
	STD 39,U
	LDA #$ee
	STD -1,U
	STD -41,U
	LDA #$00
	STD 79,U
	LEAU -201,U

	LDD #$b5be
	STD ,U
	LDA #$eb
	STD 40,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$1001
	STD -121,U
	LDA #$d1
	STD -81,U
	LDD #$dd00
	STD 119,U
	LDB #$01
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	LEAU -280,U

	LDA #$00
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	LDD #$e000
	STD -41,U
	LDA #$be
	STD -121,U
	LDA #$ee
	STD -81,U
	LEAU -201,U

	LDD #$bbe0
	STD ,U
	LDD #$be00
	STD 40,U
	RTS

