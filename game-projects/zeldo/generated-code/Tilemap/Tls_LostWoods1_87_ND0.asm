	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_87
	LEAU 481,U

	LDD #$bb1d
	STD 119,U
	LDA #$be
	STD 79,U
	LDD #$bb01
	STD -41,U
	LDD #$440d
	STD -1,U
	LDA #$4b
	STD 39,U
	LDD #$ee01
	STD -81,U
	LDA #$be
	STD -121,U
	LEAU -280,U

	LDD #$0e44
	STD -1,U
	LDD #$eeee
	STD 79,U
	LDB #$bb
	STD 39,U
	LDD #$bee1
	STD 119,U
	LDD #$0044
	STD -41,U
	STD -81,U
	LDB #$5e
	STD -121,U
	LEAU -201,U

	LDB #$e1
	STD ,U
	LDB #$41
	STD 40,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$e0dd
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -280,U

	LDA #$ee
	STD 119,U
	STD 79,U
	STD -81,U
	LDB #$ed
	STD -1,U
	STD -41,U
	LDB #$0d
	STD 39,U
	LDD #$0edd
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U
	RTS

