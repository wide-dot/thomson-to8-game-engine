	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_106
	LEAU 481,U

	LDD #$eee3
	STD 119,U
	LDB #$ee
	STD 79,U
	STD 39,U
	LDD #$3333
	STD -1,U
	STD -41,U
	STD -81,U
	LDD #$bbbb
	STD -121,U
	LEAU -280,U

	LDD #$5555
	STD 119,U
	STD 79,U
	STD -81,U
	STD -121,U
	LDD #$3353
	STD -1,U
	LDD #$5355
	STD 39,U
	LDB #$53
	STD -41,U
	LEAU -201,U

	LDD #$eeee
	STD 40,U
	LDD #$3333
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$ee3e
	STD 119,U
	LDB #$ee
	STD 79,U
	STD 39,U
	LDD #$bb3e
	STD -121,U
	LDA #$33
	STD -1,U
	STD -41,U
	STD -81,U
	LEAU -280,U

	LDA #$55
	STD 119,U
	STD 39,U
	STD -1,U
	STD -41,U
	LDA #$33
	STD 79,U
	LDA #$53
	STD -121,U
	LDA #$35
	STD -81,U
	LEAU -201,U

	LDA #$33
	STD ,U
	LDD #$eeee
	STD 40,U
	RTS

