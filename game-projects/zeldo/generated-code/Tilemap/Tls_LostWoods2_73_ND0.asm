	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_73
	LEAU 481,U

	LDD #$bbee
	STD 119,U
	LDB #$bb
	STD 79,U
	LDB #$b5
	STD 39,U
	LDD #$bebb
	STD -81,U
	LDD #$5eb5
	STD -1,U
	LDB #$bb
	STD -41,U
	LDD #$ebee
	STD -121,U
	LEAU -280,U

	LDA #$ee
	STD 119,U
	LDD #$e000
	STD 79,U
	LDA #$00
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -201,U

	LDB #$11
	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$eeeb
	STD 119,U
	LDD #$bbe5
	STD 79,U
	STD 39,U
	LDB #$b5
	STD -1,U
	LDB #$be
	STD -81,U
	LDD #$5bbb
	STD -41,U
	LDD #$eebe
	STD -121,U
	LEAU -280,U

	LDD #$000e
	STD 79,U
	LDB #$00
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LDD #$eeee
	STD 119,U
	LEAU -201,U

	LDD #$1110
	STD ,U
	LDD #$0100
	STD 40,U
	RTS

