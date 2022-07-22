	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods3_39
	LEAU 481,U

	LDD #$ee4e
	STD 119,U
	LDA #$4e
	STD 79,U
	LDB #$34
	STD 39,U
	LDD #$3433
	STD -1,U
	STD -41,U
	LDD #$e3e3
	STD -81,U
	LDB #$ee
	STD -121,U
	LEAU -280,U

	LDD #$4e4e
	STD 39,U
	LDB #$3e
	STD 79,U
	LDD #$eeee
	STD 119,U
	LDD #$343e
	STD -1,U
	LDD #$3333
	STD -41,U
	LDB #$34
	STD -81,U
	LDD #$e3e3
	STD -121,U
	LEAU -201,U

	LDA #$ee
	STD 40,U
	LDB #$ee
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$ee3e
	STD -1,U
	LDD #$e3e4
	STD 119,U
	LDB #$e3
	STD 79,U
	STD 39,U
	LDD #$3e4e
	STD -41,U
	LDD #$4e33
	STD -81,U
	LDD #$3334
	STD -121,U
	LEAU -280,U

	LDD #$34e3
	STD 119,U
	LDD #$4e3e
	STD -81,U
	LDD #$3eee
	STD -41,U
	LDD #$e3e3
	STD 79,U
	STD 39,U
	STD -1,U
	LDD #$334e
	STD -121,U
	LEAU -201,U

	LDD #$3433
	STD 40,U
	LDD #$e334
	STD ,U
	RTS

