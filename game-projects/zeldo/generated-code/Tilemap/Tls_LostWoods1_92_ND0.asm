	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_92
	LEAU 481,U

	LDD #$5e45
	STD 119,U
	LDA #$eb
	STD 39,U
	STD -1,U
	LDA #$bb
	STD 79,U
	STD -41,U
	LDA #$5b
	STD -81,U
	STD -121,U
	LEAU -280,U

	LDD #$445b
	STD 119,U
	LDA #$45
	STD 79,U
	LDD #$55b4
	STD 39,U
	LDD #$44b5
	STD -1,U
	LDD #$55e4
	STD -41,U
	LDD #$bb0e
	STD -81,U
	LDD #$5b22
	STD -121,U
	LEAU -201,U

	LDA #$5e
	STD 40,U
	LDD #$e0dd
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$45ed
	STD -41,U
	LDB #$b4
	STD 119,U
	STD 79,U
	LDB #$be
	STD 39,U
	LDB #$bd
	STD -1,U
	LDB #$0d
	STD -81,U
	STD -121,U
	LEAU -280,U

	LDD #$b4e1
	STD 119,U
	LDA #$44
	STD 79,U
	LDD #$45b0
	STD 39,U
	LDD #$5440
	STD -1,U
	LDA #$5e
	STD -41,U
	LDD #$e0e1
	STD -81,U
	LDD #$0222
	STD -121,U
	LEAU -201,U

	LDD #$22dd
	STD 40,U
	STD ,U
	RTS

