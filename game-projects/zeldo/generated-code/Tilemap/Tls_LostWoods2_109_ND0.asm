	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_109
	LEAU 481,U

	LDD #$eeee
	STD 119,U
	STD -1,U
	LDD #$3333
	STD 39,U
	STD -41,U
	LDD #$bbbb
	STD 79,U
	LDD #$6666
	STD -81,U
	LDD #$bb33
	STD -121,U
	LEAU -280,U

	LDD #$b666
	STD -121,U
	LDD #$e335
	STD 39,U
	LDB #$33
	STD -1,U
	LDD #$eeee
	STD -41,U
	STD -81,U
	LDB #$35
	STD 119,U
	STD 79,U
	LEAU -201,U

	LDD #$b55b
	STD 40,U
	LDD #$bbbb
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$33bb
	STD -41,U
	LDA #$bb
	STD 79,U
	STD -121,U
	LDD #$3333
	STD 39,U
	LDD #$ee55
	STD -1,U
	LDB #$ee
	STD 119,U
	LDD #$66bb
	STD -81,U
	LEAU -280,U

	LDA #$ee
	STD 119,U
	LDD #$3355
	STD 79,U
	LDD #$ee66
	STD 39,U
	STD -1,U
	LDD #$66e6
	STD -121,U
	LDD #$eee5
	STD -81,U
	LDD #$3365
	STD -41,U
	LEAU -201,U

	LDD #$bbeb
	STD 40,U
	LDD #$55e3
	STD ,U
	RTS

