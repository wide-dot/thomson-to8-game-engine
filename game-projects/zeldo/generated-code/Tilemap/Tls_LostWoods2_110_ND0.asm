	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_110
	LEAU 481,U

	LDD #$eeee
	STD 119,U
	LDD #$e5e3
	STD 79,U
	LDB #$e5
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	LDD #$3e35
	STD -121,U
	LEAU -280,U

	STD 119,U
	LDA #$e5
	STD -1,U
	STD -41,U
	STD -81,U
	LDA #$e3
	STD 39,U
	LDA #$33
	STD 79,U
	LDD #$e3e5
	STD -121,U
	LEAU -201,U

	LDB #$e3
	STD 40,U
	LDD #$e5ee
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$3355
	STD 39,U
	STD -121,U
	LDB #$33
	STD 79,U
	LDD #$53ee
	STD 119,U
	LDB #$55
	STD -1,U
	STD -41,U
	STD -81,U
	LEAU -280,U

	LDB #$5b
	STD 79,U
	LDB #$5e
	STD 39,U
	STD -1,U
	LDB #$55
	STD -121,U
	LDA #$33
	STD 119,U
	LDB #$5e
	STD -41,U
	LDB #$55
	STD -81,U
	LEAU -201,U

	LDD #$5333
	STD 40,U
	LDD #$55ee
	STD ,U
	RTS

