	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_45
	LEAU 481,U

	LDD #$b5bb
	STD 119,U
	LDA #$55
	STD 79,U
	LDD #$be5e
	STD -41,U
	LDA #$5b
	STD -1,U
	LDB #$bb
	STD 39,U
	LDD #$eebe
	STD -81,U
	LDD #$bbeb
	STD -121,U
	LEAU -280,U

	LDD #$ee00
	STD 39,U
	LDB #$e0
	STD 79,U
	LDD #$bbee
	STD 119,U
	LDD #$0000
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$ebbb
	STD 39,U
	LDA #$bb
	STD 79,U
	STD -1,U
	LDB #$ee
	STD 119,U
	LDB #$5b
	STD -41,U
	LDD #$b5bb
	STD -81,U
	LDB #$ee
	STD -121,U
	LEAU -280,U

	LDD #$ee00
	STD 79,U
	STD 39,U
	LDD #$beee
	STD 119,U
	LDD #$0000
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -201,U

	LDB #$11
	STD ,U
	LDB #$01
	STD 40,U
	RTS

