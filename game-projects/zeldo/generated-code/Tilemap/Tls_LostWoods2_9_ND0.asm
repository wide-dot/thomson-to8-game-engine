	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_9
	LEAU 481,U

	LDD #$55be
	STD -121,U
	LDD #$5455
	STD 39,U
	LDA #$55
	STD 119,U
	STD 79,U
	LDB #$5b
	STD -1,U
	LDB #$5e
	STD -41,U
	STD -81,U
	LEAU -280,U

	LDB #$be
	STD 119,U
	STD 79,U
	LDB #$ee
	STD 39,U
	STD -1,U
	LDA #$5b
	STD -41,U
	LDA #$5e
	STD -81,U
	STD -121,U
	LEAU -201,U

	LDD #$bebe
	STD ,U
	LDB #$ee
	STD 40,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$555b
	STD 119,U
	LDB #$be
	STD 79,U
	LDB #$ee
	STD 39,U
	STD -81,U
	STD -121,U
	LDA #$54
	STD -41,U
	LDA #$44
	STD -1,U
	LEAU -280,U

	LDD #$beeb
	STD 39,U
	LDA #$5b
	STD 79,U
	LDD #$55ee
	STD 119,U
	LDD #$eebb
	STD -1,U
	LDB #$be
	STD -41,U
	STD -81,U
	LDB #$bb
	STD -121,U
	LEAU -201,U

	STD 40,U
	LDB #$b4
	STD ,U
	RTS

