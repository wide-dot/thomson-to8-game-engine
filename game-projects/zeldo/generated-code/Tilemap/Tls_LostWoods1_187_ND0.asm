	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_187
	LEAU 481,U

	LDD #$ebbb
	STD 119,U
	LDD #$4be5
	STD -41,U
	LDD #$bebe
	STD 39,U
	LDD #$b4eb
	STD -1,U
	LDD #$eeb5
	STD 79,U
	LDA #$bb
	STD -81,U
	LDA #$44
	STD -121,U
	LEAU -280,U

	LDD #$ee55
	STD 79,U
	LDA #$bb
	STD 119,U
	LDD #$ebee
	STD 39,U
	LDD #$b5ed
	STD -1,U
	LDA #$e5
	STD -41,U
	LDD #$dedd
	STD -81,U
	LDA #$dd
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$b4bd
	STD -41,U
	LDD #$4b5e
	STD 39,U
	LDB #$5d
	STD -81,U
	LDD #$e4ee
	STD -1,U
	LDD #$bb5e
	STD 119,U
	STD 79,U
	LDD #$beed
	STD -121,U
	LEAU -280,U

	LDA #$ee
	STD 119,U
	LDD #$bbdd
	STD 79,U
	LDA #$b5
	STD 39,U
	LDA #$dd
	STD -121,U
	LDA #$ee
	STD -81,U
	LDA #$55
	STD -1,U
	STD -41,U
	LEAU -201,U

	LDA #$dd
	STD 40,U
	STD ,U
	RTS

