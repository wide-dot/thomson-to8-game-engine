	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_128
	LEAU 481,U

	LDD #$dd22
	STD 119,U
	LDB #$e4
	STD -81,U
	STD -121,U
	LDD #$22eb
	STD 39,U
	STD -1,U
	LDB #$e4
	STD -41,U
	LDB #$2e
	STD 79,U
	LEAU -280,U

	LDD #$ddee
	STD 119,U
	LDB #$eb
	STD -121,U
	LDA #$b4
	STD -1,U
	LDA #$bb
	STD 39,U
	LDB #$e4
	STD -41,U
	LDA #$ee
	STD 79,U
	STD -81,U
	LEAU -201,U

	LDD #$dddb
	STD 40,U
	LDB #$de
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$ddbb
	STD -121,U
	LDD #$22ee
	STD 79,U
	LDB #$be
	STD 39,U
	LDB #$bb
	STD -1,U
	STD -41,U
	LDA #$7d
	STD -81,U
	LDD #$dd22
	STD 119,U
	LEAU -280,U

	LDB #$4b
	STD -121,U
	LDD #$ee4e
	STD 79,U
	LDD #$bbb4
	STD 39,U
	LDB #$bb
	STD -41,U
	LDD #$b44b
	STD -1,U
	LDD #$eebb
	STD -81,U
	LDD #$ddeb
	STD 119,U
	LEAU -201,U

	LDB #$ed
	STD ,U
	LDB #$be
	STD 40,U
	RTS

