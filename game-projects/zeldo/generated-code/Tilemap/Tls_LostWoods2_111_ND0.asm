	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_111
	LEAU 481,U

	LDD #$3ee3
	STD 39,U
	LDB #$e5
	STD -1,U
	STD -41,U
	LDB #$e3
	STD -121,U
	LDA #$33
	STD 79,U
	LDB #$e5
	STD -81,U
	LDA #$ee
	STD 119,U
	LEAU -280,U

	LDD #$b5e3
	STD 119,U
	LDD #$e5e5
	STD 79,U
	LDD #$3ee3
	STD -41,U
	LDD #$eee5
	STD -1,U
	LDA #$eb
	STD 39,U
	LDD #$35e3
	STD -81,U
	LDB #$e5
	STD -121,U
	LEAU -201,U

	LDA #$33
	STD 40,U
	LDA #$ee
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$ee53
	STD 119,U
	LDD #$b3e3
	STD -1,U
	LDA #$e3
	STD 39,U
	STD -41,U
	LDB #$ee
	STD -81,U
	STD -121,U
	LDD #$33e3
	STD 79,U
	LEAU -280,U

	LDB #$33
	STD -121,U
	LDD #$3553
	STD 39,U
	STD -1,U
	STD -41,U
	LDB #$3e
	STD 119,U
	STD 79,U
	LDB #$33
	STD -81,U
	LEAU -201,U

	LDD #$3e53
	STD 40,U
	LDA #$ee
	STD ,U
	RTS

