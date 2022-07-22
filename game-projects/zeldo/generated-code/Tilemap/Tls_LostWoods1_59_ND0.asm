	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_59
	LEAU 481,U

	LDD #$d111
	STD 119,U
	LDD #$1eee
	STD 79,U
	LDD #$ee4e
	STD 39,U
	LDD #$ebbe
	STD -1,U
	LDD #$e4b4
	STD -41,U
	LDD #$eebb
	STD -81,U
	LDB #$ee
	STD -121,U
	LEAU -280,U

	LDD #$2222
	STD -81,U
	STD -121,U
	LDA #$2e
	STD 79,U
	LDA #$12
	STD 39,U
	LDA #$11
	STD -1,U
	LDA #$21
	STD -41,U
	LDA #$ee
	STD 119,U
	LEAU -201,U

	LDA #$22
	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$111d
	STD 119,U
	LDD #$eee1
	STD 79,U
	LDB #$44
	STD -81,U
	LDB #$4b
	STD -121,U
	LDD #$e44e
	STD -1,U
	LDD #$eebb
	STD -41,U
	LDD #$bebe
	STD 39,U
	LEAU -280,U

	LDA #$e2
	STD 119,U
	LDD #$2121
	STD 79,U
	LDD #$1120
	STD 39,U
	STD -1,U
	STD -41,U
	LDB #$2e
	STD -81,U
	STD -121,U
	LEAU -201,U

	LDD #$2220
	STD ,U
	LDA #$12
	STD 40,U
	RTS

