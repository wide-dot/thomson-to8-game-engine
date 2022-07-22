	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods3_108
	LEAU 481,U

	LDD #$22ee
	STD -81,U
	STD -121,U
	LDD #$dd22
	STD 79,U
	LDA #$22
	STD 39,U
	LDB #$2e
	STD -1,U
	STD -41,U
	LDD #$ddd2
	STD 119,U
	LEAU -280,U

	LDD #$eeee
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$2233
	STD -81,U
	LDB #$ee
	STD 39,U
	LDB #$e3
	STD -1,U
	STD -41,U
	LDD #$dd22
	STD 119,U
	LDB #$2e
	STD 79,U
	LDD #$2e33
	STD -121,U
	LEAU -280,U

	LDA #$ee
	STD 119,U
	LDB #$34
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	LDB #$35
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U
	RTS

