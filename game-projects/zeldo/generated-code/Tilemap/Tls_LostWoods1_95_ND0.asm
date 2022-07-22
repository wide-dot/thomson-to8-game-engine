	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_95
	LEAU 481,U

	LDD #$eebe
	STD 119,U
	LDB #$b4
	STD -121,U
	LDD #$bbbe
	STD 79,U
	LDD #$b4bb
	STD 39,U
	STD -1,U
	LDD #$bb4b
	STD -41,U
	STD -81,U
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

	LDD #$ebb4
	STD 119,U
	LDD #$bbbb
	STD -41,U
	LDD #$b4eb
	STD -1,U
	LDD #$e4b4
	STD 79,U
	STD 39,U
	LDD #$bebe
	STD -81,U
	STD -121,U
	LEAU -280,U

	LDD #$00ee
	STD 39,U
	LDA #$0e
	STD 79,U
	LDD #$eebe
	STD 119,U
	LDD #$0000
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -201,U

	STD 40,U
	LDA #$10
	STD ,U
	RTS

