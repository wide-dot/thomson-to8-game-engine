	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_146
	LEAU 481,U

	LDD #$bbe0
	STD -41,U
	LDD #$ebe1
	STD 79,U
	LDA #$b4
	STD 39,U
	LDA #$4e
	STD -1,U
	LDA #$be
	STD 119,U
	LDD #$e4b0
	STD -81,U
	LDD #$b4be
	STD -121,U
	LEAU -280,U

	LDA #$bb
	STD 119,U
	STD 79,U
	STD 39,U
	LDD #$b5e1
	STD -81,U
	STD -121,U
	LDD #$e5e0
	STD -41,U
	LDD #$eeb0
	STD -1,U
	LEAU -201,U

	LDD #$bee1
	STD 40,U
	LDA #$bb
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$ee12
	STD 119,U
	LDA #$be
	STD 79,U
	STD -41,U
	LDD #$bb11
	STD -81,U
	LDD #$eb12
	STD -1,U
	LDA #$4b
	STD 39,U
	LDB #$11
	STD -121,U
	LEAU -280,U

	STD 119,U
	LDA #$ee
	STD 79,U
	LDD #$b512
	STD -121,U
	LDA #$eb
	STD -41,U
	STD -81,U
	LDD #$5511
	STD 39,U
	STD -1,U
	LEAU -201,U

	LDB #$12
	STD 40,U
	LDA #$ee
	STD ,U
	RTS

