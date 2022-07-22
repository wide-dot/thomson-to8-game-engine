	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_153
	LEAU 481,U

	LDD #$2222
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	LDB #$21
	STD -121,U
	LEAU -280,U

	LDB #$20
	STD 119,U
	LDD #$eeeb
	STD -41,U
	LDD #$00ee
	STD 39,U
	LDD #$0eeb
	STD -1,U
	LDD #$110e
	STD 79,U
	LDD #$ebeb
	STD -81,U
	STD -121,U
	LEAU -201,U

	LDB #$be
	STD 40,U
	LDA #$b4
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$2200
	STD -81,U
	LDB #$11
	STD -41,U
	LDB #$22
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	LDB #$ee
	STD -121,U
	LEAU -280,U

	STD 119,U
	LDD #$ee44
	STD -81,U
	LDD #$00eb
	STD 39,U
	LDD #$eebe
	STD -1,U
	LDB #$bb
	STD -41,U
	LDD #$10eb
	STD 79,U
	LDD #$beb4
	STD -121,U
	LEAU -201,U

	LDD #$bbbb
	STD ,U
	LDA #$be
	STD 40,U
	RTS

