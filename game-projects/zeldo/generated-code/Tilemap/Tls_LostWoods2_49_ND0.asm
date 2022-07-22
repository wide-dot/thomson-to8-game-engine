	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_49
	LEAU 481,U

	LDD #$0ebe
	STD 119,U
	STD 79,U
	LDD #$e5bb
	STD 39,U
	STD -1,U
	LDD #$bb5b
	STD -41,U
	STD -81,U
	LDD #$eeb5
	STD -121,U
	LEAU -280,U

	LDD #$00ee
	STD 79,U
	STD 39,U
	LDD #$eeeb
	STD 119,U
	LDD #$0000
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -201,U

	LDA #$11
	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$ebb5
	STD 119,U
	LDD #$b5eb
	STD -1,U
	LDD #$e5b5
	STD 79,U
	STD 39,U
	LDD #$bbbb
	STD -41,U
	LDD #$bebe
	STD -81,U
	STD -121,U
	LEAU -280,U

	LDA #$ee
	STD 119,U
	LDD #$0eee
	STD 79,U
	LDD #$0000
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LDB #$ee
	STD 39,U
	LEAU -201,U

	LDB #$00
	STD 40,U
	LDA #$10
	STD ,U
	RTS

