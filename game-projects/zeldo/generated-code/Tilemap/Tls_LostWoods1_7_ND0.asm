	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_7
	LEAU 481,U

	LDD #$b4bb
	STD 119,U
	LDA #$44
	STD 79,U
	LDA #$4b
	STD 39,U
	LDD #$bbeb
	STD -121,U
	LDD #$be4e
	STD -41,U
	LDD #$eebe
	STD -81,U
	LDD #$4b4e
	STD -1,U
	LEAU -280,U

	LDD #$eee0
	STD 79,U
	LDD #$bbee
	STD 119,U
	LDD #$ee00
	STD 39,U
	LDA #$00
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$bbe0
	STD 119,U
	LDD #$b4bb
	STD -81,U
	LDD #$ebbe
	STD 39,U
	LDD #$bb4b
	STD -41,U
	LDB #$be
	STD 79,U
	LDB #$bb
	STD -1,U
	LDD #$b4ee
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

