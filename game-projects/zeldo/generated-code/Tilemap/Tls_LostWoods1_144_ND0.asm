	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_144
	LEAU 481,U

	LDD #$b4e1
	STD 119,U
	STD 79,U
	STD 39,U
	LDA #$bb
	STD -1,U
	LDB #$e0
	STD -41,U
	LDB #$b0
	STD -81,U
	LDB #$be
	STD -121,U
	LEAU -280,U

	STD 119,U
	LDA #$eb
	STD 39,U
	LDA #$be
	STD 79,U
	LDD #$b4b0
	STD -1,U
	LDD #$4ee0
	STD -41,U
	LDD #$bbe1
	STD -81,U
	LDA #$e4
	STD -121,U
	LEAU -201,U

	LDA #$bb
	STD ,U
	LDA #$b4
	STD 40,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$bb12
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	LDB #$11
	STD -81,U
	STD -121,U
	LEAU -280,U

	STD 119,U
	LDB #$12
	STD -121,U
	LDD #$ee11
	STD 79,U
	LDA #$be
	STD 39,U
	LDB #$12
	STD -81,U
	LDD #$4b11
	STD -1,U
	LDD #$eb12
	STD -41,U
	LEAU -201,U

	LDA #$4b
	STD 40,U
	STD ,U
	RTS

