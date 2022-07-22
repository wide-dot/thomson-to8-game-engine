	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods3_104
	LEAU 481,U

	LDD #$33dd
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LDA #$ee
	STD 79,U
	LDA #$3e
	STD 39,U
	LDA #$2d
	STD 119,U
	LEAU -280,U

	LDA #$33
	STD 119,U
	LDD #$4333
	STD -41,U
	STD -81,U
	LDD #$44ee
	STD 39,U
	LDB #$3e
	STD -1,U
	LDB #$33
	STD -121,U
	LDD #$432d
	STD 79,U
	LEAU -201,U

	LDD #$5433
	STD ,U
	LDA #$44
	STD 40,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$2ddd
	STD 39,U
	LDA #$dd
	STD 119,U
	STD 79,U
	LDA #$ed
	STD -1,U
	LDA #$e2
	STD -41,U
	LDA #$3e
	STD -81,U
	STD -121,U
	LEAU -280,U

	STD 119,U
	LDD #$333e
	STD -121,U
	LDB #$2d
	STD -1,U
	LDB #$ed
	STD -41,U
	LDB #$e2
	STD -81,U
	LDB #$dd
	STD 79,U
	STD 39,U
	LEAU -201,U

	LDD #$343e
	STD ,U
	LDA #$33
	STD 40,U
	RTS

