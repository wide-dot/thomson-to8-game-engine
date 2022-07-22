	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_180
	LEAU 481,U

	LDD #$eeeb
	STD 119,U
	LDA #$00
	STD 79,U
	LDB #$ee
	STD 39,U
	LDD #$100e
	STD -1,U
	LDA #$11
	STD -41,U
	STD -81,U
	LDB #$00
	STD -121,U
	LEAU -280,U

	STD 119,U
	LDD #$0110
	STD 79,U
	LDA #$00
	STD 39,U
	STD -1,U
	STD -41,U
	LDA #$10
	STD -81,U
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$eeed
	STD 119,U
	LDD #$0e1d
	STD 79,U
	LDD #$000d
	STD 39,U
	LDD #$10bb
	STD -121,U
	LDB #$4b
	STD -81,U
	LDD #$00e1
	STD -1,U
	LDB #$ee
	STD -41,U
	LEAU -280,U

	LDD #$01e2
	STD -41,U
	LDB #$e0
	STD -81,U
	LDB #$ee
	STD -121,U
	LDD #$11eb
	STD 119,U
	LDB #$ee
	STD 79,U
	LDB #$e0
	STD 39,U
	LDB #$e2
	STD -1,U
	LEAU -201,U

	LDD #$01ee
	STD 40,U
	STD ,U
	RTS

