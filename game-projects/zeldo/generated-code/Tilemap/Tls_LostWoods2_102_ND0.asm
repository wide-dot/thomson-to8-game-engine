	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_102
	LEAU 481,U

	LDD #$e3ee
	STD 119,U
	LDB #$33
	STD -41,U
	STD -81,U
	LDA #$ee
	STD -1,U
	LDB #$ee
	STD 79,U
	STD 39,U
	LDD #$e3bb
	STD -121,U
	LEAU -280,U

	LDB #$55
	STD 119,U
	STD 79,U
	LDB #$53
	STD -41,U
	LDB #$55
	STD -81,U
	STD -121,U
	LDD #$ee53
	STD 39,U
	LDB #$33
	STD -1,U
	LEAU -201,U

	LDA #$e3
	STD ,U
	LDD #$eeee
	STD 40,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$3333
	STD -1,U
	STD -41,U
	STD -81,U
	LDD #$eeee
	STD 79,U
	STD 39,U
	LDA #$3e
	STD 119,U
	LDD #$5bbb
	STD -121,U
	LEAU -280,U

	LDD #$5555
	STD 119,U
	LDB #$53
	STD -121,U
	LDB #$33
	STD 79,U
	LDB #$35
	STD -81,U
	LDD #$3555
	STD 39,U
	STD -41,U
	LDA #$33
	STD -1,U
	LEAU -201,U

	LDD #$eeee
	STD 40,U
	LDD #$3333
	STD ,U
	RTS

