	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_56
	LEAU 481,U

	LDD #$04ee
	STD 119,U
	LDA #$05
	STD 79,U
	LDA #$e5
	STD 39,U
	STD -1,U
	LDA #$eb
	STD -121,U
	LDA #$ee
	STD -41,U
	STD -81,U
	LEAU -280,U

	LDA #$eb
	STD 119,U
	LDB #$e4
	STD 79,U
	LDD #$0ee5
	STD -1,U
	LDD #$0bb4
	STD 39,U
	LDD #$1eee
	STD -41,U
	LDD #$10bb
	STD -81,U
	LDA #$11
	STD -121,U
	LEAU -201,U

	LDA #$21
	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$b4be
	STD 119,U
	STD 79,U
	LDB #$ee
	STD 39,U
	STD -1,U
	STD -41,U
	LDA #$5b
	STD -121,U
	LDA #$54
	STD -81,U
	LEAU -280,U

	LDA #$e5
	STD 119,U
	LDD #$eebe
	STD -121,U
	LDD #$be55
	STD 39,U
	STD -41,U
	LDB #$44
	STD -1,U
	LDB #$ee
	STD -81,U
	LDD #$bb4b
	STD 79,U
	LEAU -201,U

	LDD #$0eb4
	STD 40,U
	LDA #$10
	STD ,U
	RTS

