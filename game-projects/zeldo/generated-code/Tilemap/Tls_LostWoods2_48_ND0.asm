	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_48
	LEAU 481,U

	LDD #$b5bb
	STD 119,U
	LDA #$55
	STD 79,U
	LDA #$5b
	STD 39,U
	LDD #$eebe
	STD -81,U
	LDD #$be5e
	STD -41,U
	LDA #$5b
	STD -1,U
	LDD #$bbeb
	STD -121,U
	LEAU -280,U

	LDB #$ee
	STD 119,U
	LDD #$eee0
	STD 79,U
	LDD #$0000
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LDA #$ee
	STD 39,U
	LEAU -201,U

	LDA #$00
	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$bbe0
	STD 119,U
	LDB #$be
	STD 79,U
	LDB #$bb
	STD -1,U
	LDD #$ebbe
	STD 39,U
	LDD #$bb5b
	STD -41,U
	LDD #$b5bb
	STD -81,U
	LDB #$ee
	STD -121,U
	LEAU -280,U

	LDA #$be
	STD 119,U
	LDD #$ee00
	STD 79,U
	STD 39,U
	LDA #$00
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -201,U

	LDB #$01
	STD 40,U
	LDB #$11
	STD ,U
	RTS

