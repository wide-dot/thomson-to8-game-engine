	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_189
	LEAU 481,U

	LDD #$ebbe
	STD 119,U
	LDB #$bb
	STD 79,U
	STD -41,U
	LDA #$ee
	STD 39,U
	LDB #$b5
	STD -1,U
	LDD #$db5e
	STD -121,U
	LDA #$2b
	STD -81,U
	LEAU -280,U

	LDB #$eb
	STD 79,U
	LDD #$dbe4
	STD 119,U
	LDD #$eebb
	STD 39,U
	STD -121,U
	LDB #$4b
	STD -1,U
	LDB #$44
	STD -41,U
	STD -81,U
	LEAU -201,U

	LDB #$bb
	STD 40,U
	LDB #$4b
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$eebe
	STD 119,U
	LDB #$bb
	STD 79,U
	LDD #$be55
	STD 39,U
	LDA #$bb
	STD -1,U
	STD -41,U
	LDD #$e5bb
	STD -121,U
	LDD #$b5ee
	STD -81,U
	LEAU -280,U

	LDD #$55b4
	STD 119,U
	LDD #$b54b
	STD 79,U
	LDD #$5ebe
	STD -1,U
	STD -41,U
	STD -81,U
	LDB #$bb
	STD -121,U
	LDD #$beeb
	STD 39,U
	LEAU -201,U

	LDD #$5ebb
	STD 40,U
	STD ,U
	RTS

