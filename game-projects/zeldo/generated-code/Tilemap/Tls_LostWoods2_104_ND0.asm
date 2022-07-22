	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_104
	LEAU 481,U

	LDD #$ebee
	STD 119,U
	LDD #$e653
	STD 79,U
	LDA #$eb
	STD 39,U
	STD -1,U
	LDD #$e3b5
	STD -121,U
	LDD #$e5bb
	STD -81,U
	LDD #$eb66
	STD -41,U
	LEAU -280,U

	LDD #$eebb
	STD 119,U
	LDA #$be
	STD 79,U
	LDD #$53ee
	STD 39,U
	LDD #$3b33
	STD -1,U
	LDD #$355b
	STD -41,U
	LDD #$5353
	STD -81,U
	LDD #$5555
	STD -121,U
	LEAU -201,U

	LDD #$eeee
	STD 40,U
	LDD #$3333
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$55ee
	STD 119,U
	LDB #$55
	STD 39,U
	LDD #$5333
	STD 79,U
	LDD #$6553
	STD -1,U
	LDD #$b666
	STD -41,U
	LDD #$bbbb
	STD -81,U
	LDB #$b5
	STD -121,U
	LEAU -280,U

	LDD #$5bbb
	STD 119,U
	LDA #$3b
	STD 79,U
	LDD #$eeee
	STD 39,U
	LDD #$3333
	STD -1,U
	LDD #$5535
	STD -81,U
	LDD #$bbbb
	STD -41,U
	LDD #$3353
	STD -121,U
	LEAU -201,U

	LDB #$33
	STD ,U
	LDD #$eeee
	STD 40,U
	RTS

