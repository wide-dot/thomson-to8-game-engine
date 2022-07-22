	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_108
	LEAU 481,U

	LDD #$ddee
	STD 119,U
	LDB #$bb
	STD 79,U
	LDB #$33
	STD 39,U
	LDD #$de55
	STD -1,U
	LDD #$e3bb
	STD -121,U
	LDA #$eb
	STD -81,U
	LDD #$d35b
	STD -41,U
	LEAU -280,U

	LDA #$e5
	STD 119,U
	LDB #$56
	STD -41,U
	LDB #$65
	STD 79,U
	LDB #$66
	STD 39,U
	STD -1,U
	LDD #$e356
	STD -81,U
	LDB #$66
	STD -121,U
	LEAU -201,U

	LDD #$ebbb
	STD 40,U
	LDB #$33
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$55e6
	STD -81,U
	LDB #$e3
	STD -121,U
	LDD #$ebbb
	STD 79,U
	LDD #$3333
	STD 39,U
	LDD #$b5ee
	STD -1,U
	LDD #$35e3
	STD -41,U
	LDD #$deee
	STD 119,U
	LEAU -280,U

	LDD #$5be5
	STD 79,U
	LDA #$53
	STD 119,U
	LDA #$3b
	STD 39,U
	LDB #$e3
	STD -1,U
	LDD #$bbee
	STD -41,U
	STD -81,U
	LDB #$56
	STD -121,U
	LEAU -201,U

	LDD #$b555
	STD ,U
	LDD #$bb5b
	STD 40,U
	RTS

