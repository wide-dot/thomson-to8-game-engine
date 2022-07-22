	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_190
	LEAU 481,U

	LDD #$ee5b
	STD -81,U
	LDD #$bbbe
	STD 79,U
	LDA #$55
	STD 39,U
	STD -1,U
	LDB #$5b
	STD -41,U
	LDD #$ee4e
	STD 119,U
	LDD #$bb55
	STD -121,U
	LEAU -280,U

	LDD #$e4bb
	STD -121,U
	LDD #$bbe5
	STD 79,U
	LDD #$4eeb
	STD 39,U
	LDD #$beb5
	STD -1,U
	LDA #$ee
	STD -41,U
	LDD #$ebbb
	STD -81,U
	LDD #$4455
	STD 119,U
	LEAU -201,U

	LDD #$e4bb
	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$be4e
	STD 119,U
	LDB #$be
	STD 79,U
	LDB #$bb
	STD 39,U
	LDA #$5e
	STD -1,U
	LDD #$bbee
	STD -81,U
	LDA #$5e
	STD -41,U
	LDA #$ee
	STD -121,U
	LEAU -280,U

	LDD #$4b5b
	STD -1,U
	LDD #$e4ee
	STD 79,U
	LDD #$445b
	STD 39,U
	STD -121,U
	LDD #$beee
	STD 119,U
	LDD #$bb5b
	STD -41,U
	STD -81,U
	LEAU -201,U

	LDA #$4b
	STD ,U
	LDA #$44
	STD 40,U
	RTS

