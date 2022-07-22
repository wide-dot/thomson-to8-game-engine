	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_172
	LEAU 481,U

	LDD #$bb4b
	STD 119,U
	LDD #$5b4e
	STD 79,U
	LDD #$54eb
	STD -41,U
	LDD #$44be
	STD -1,U
	LDD #$454e
	STD 39,U
	LDB #$5b
	STD -81,U
	LDB #$5e
	STD -121,U
	LEAU -280,U

	LDD #$bb45
	STD 39,U
	STD -81,U
	LDA #$5e
	STD 79,U
	LDD #$544e
	STD 119,U
	LDD #$eb45
	STD -1,U
	STD -41,U
	LDA #$5b
	STD -121,U
	LEAU -201,U

	STD 40,U
	LDD #$445b
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$eb0d
	STD 119,U
	LDD #$bbdd
	STD 79,U
	LDD #$be1d
	STD 39,U
	LDA #$5b
	STD -1,U
	LDD #$5501
	STD -41,U
	LDD #$44e1
	STD -81,U
	LDD #$b4be
	STD -121,U
	LEAU -280,U

	LDD #$45b4
	STD 79,U
	STD 39,U
	LDB #$be
	STD -1,U
	LDB #$bd
	STD -41,U
	LDD #$b5bb
	STD 119,U
	LDD #$45ed
	STD -81,U
	LDB #$0d
	STD -121,U
	LEAU -201,U

	LDD #$b4e1
	STD ,U
	LDD #$450d
	STD 40,U
	RTS

