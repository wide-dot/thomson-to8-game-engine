	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_75
	LEAU 481,U

	LDD #$d2e2
	STD 119,U
	LDD #$deee
	STD 79,U
	LDD #$2ede
	STD 39,U
	LDB #$2e
	STD -1,U
	LDA #$ee
	STD -41,U
	LDA #$ed
	STD -81,U
	LDA #$e2
	STD -121,U
	LEAU -280,U

	LDB #$e2
	STD 119,U
	LDD #$2e2e
	STD 79,U
	LDD #$e2d2
	STD 39,U
	STD -1,U
	LDD #$2ee2
	STD -81,U
	LDD #$ed2e
	STD -41,U
	LDD #$d2e2
	STD -121,U
	LEAU -201,U

	LDB #$ed
	STD 40,U
	LDD #$dd2e
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$222d
	STD 119,U
	LDD #$eee2
	STD 79,U
	LDD #$2d2e
	STD -1,U
	LDD #$2ed2
	STD 39,U
	LDD #$e2ee
	STD -41,U
	LDB #$2d
	STD -81,U
	LDA #$2e
	STD -121,U
	LEAU -280,U

	LDB #$2e
	STD 119,U
	STD 39,U
	LDB #$2d
	STD -1,U
	STD -41,U
	LDD #$eeee
	STD 79,U
	LDA #$e2
	STD -81,U
	LDD #$d2e2
	STD -121,U
	LEAU -201,U

	LDB #$ed
	STD 40,U
	LDD #$ee2d
	STD ,U
	RTS

