	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_90
	LEAU 481,U

	LDD #$0110
	STD 119,U
	LDA #$00
	STD 79,U
	STD 39,U
	STD -1,U
	LDA #$10
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -280,U

	STD 119,U
	LDD #$010e
	STD -1,U
	LDD #$0010
	STD 79,U
	STD 39,U
	LDD #$110e
	STD -41,U
	LDB #$0d
	STD -81,U
	LDB #$ed
	STD -121,U
	LEAU -201,U

	LDD #$eedd
	STD ,U
	LDA #$00
	STD 40,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$01e2
	STD -1,U
	LDB #$e0
	STD -41,U
	LDB #$ee
	STD -81,U
	STD -121,U
	LDA #$11
	STD 119,U
	LDB #$e0
	STD 79,U
	LDB #$e2
	STD 39,U
	LEAU -280,U

	LDD #$01ee
	STD 119,U
	LDA #$11
	STD 79,U
	LDB #$ed
	STD 39,U
	LDD #$10dd
	STD -81,U
	LDA #$11
	STD -1,U
	STD -41,U
	LDA #$00
	STD -121,U
	LEAU -201,U

	LDA #$ed
	STD ,U
	LDA #$0e
	STD 40,U
	RTS

