	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_113
	LEAU 481,U

	LDD #$eeee
	STD 119,U
	LDD #$bb53
	STD 79,U
	LDD #$ee3e
	STD -1,U
	LDD #$33e5
	STD 39,U
	LDB #$33
	STD -41,U
	STD -121,U
	LDA #$66
	STD -81,U
	LEAU -280,U

	LDD #$ee55
	STD -41,U
	STD -81,U
	LDD #$3553
	STD 79,U
	LDB #$55
	STD 39,U
	LDA #$33
	STD -1,U
	LDD #$3533
	STD 119,U
	LDD #$6655
	STD -121,U
	LEAU -201,U

	LDD #$bb33
	STD ,U
	LDD #$5b55
	STD 40,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$eeee
	STD 119,U
	LDA #$bb
	STD 79,U
	LDB #$e3
	STD -81,U
	LDD #$33ee
	STD 39,U
	LDD #$553e
	STD -1,U
	LDD #$bb35
	STD -121,U
	LDB #$5e
	STD -41,U
	LEAU -280,U

	LDB #$3e
	STD 119,U
	LDD #$5533
	STD 79,U
	LDD #$e553
	STD -81,U
	LDD #$6533
	STD -41,U
	LDA #$66
	STD 39,U
	STD -1,U
	LDD #$e653
	STD -121,U
	LEAU -201,U

	LDA #$eb
	STD 40,U
	LDD #$e355
	STD ,U
	RTS

