	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_112
	LEAU 481,U

	LDD #$eeee
	STD 119,U
	LDD #$bbbb
	STD 79,U
	STD -121,U
	LDD #$3333
	STD 39,U
	LDD #$55ee
	STD -1,U
	LDD #$5b33
	STD -41,U
	LDD #$bb66
	STD -81,U
	LEAU -280,U

	LDD #$5bee
	STD 119,U
	LDA #$65
	STD 79,U
	LDD #$66e3
	STD 39,U
	STD -1,U
	LDD #$56ee
	STD -41,U
	STD -81,U
	LDD #$66b6
	STD -121,U
	LEAU -201,U

	LDD #$bbb5
	STD 40,U
	LDD #$33bb
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$eeee
	STD 119,U
	STD -1,U
	LDD #$3333
	STD 39,U
	LDD #$bbbb
	STD 79,U
	LDD #$e333
	STD -41,U
	LDD #$e666
	STD -81,U
	LDD #$e3bb
	STD -121,U
	LEAU -280,U

	LDD #$e5ee
	STD 119,U
	STD 39,U
	LDB #$33
	STD 79,U
	LDA #$ee
	STD -41,U
	LDD #$e3ee
	STD -1,U
	LDA #$ee
	STD -81,U
	LDD #$5666
	STD -121,U
	LEAU -201,U

	LDD #$5bbb
	STD 40,U
	LDD #$5555
	STD ,U
	RTS

