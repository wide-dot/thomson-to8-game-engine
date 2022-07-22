	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_176
	LEAU 481,U

	LDD #$dd01
	STD -1,U
	LDB #$00
	STD -41,U
	LDD #$de11
	STD 79,U
	LDA #$dd
	STD 39,U
	LDA #$2b
	STD 119,U
	LDD #$dde0
	STD -81,U
	LDB #$de
	STD -121,U
	LEAU -280,U

	LDB #$dd
	STD 119,U
	STD 79,U
	STD 39,U
	LDD #$d01d
	STD -1,U
	LDD #$de01
	STD -41,U
	LDB #$e0
	STD -81,U
	STD -121,U
	LEAU -201,U

	LDD #$ddbb
	STD ,U
	LDD #$deee
	STD 40,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$dd01
	STD -81,U
	LDB #$00
	STD -121,U
	LDD #$e010
	STD 79,U
	STD 39,U
	LDD #$d011
	STD -1,U
	LDA #$de
	STD -41,U
	LDD #$e100
	STD 119,U
	LEAU -280,U

	LDD #$ddee
	STD 119,U
	LDB #$d0
	STD 79,U
	LDB #$de
	STD 39,U
	LDD #$111b
	STD -1,U
	LDD #$4eeb
	STD -81,U
	LDD #$e00b
	STD -41,U
	LDD #$44eb
	STD -121,U
	LEAU -201,U

	LDD #$4bbe
	STD ,U
	LDD #$44bb
	STD 40,U
	RTS

