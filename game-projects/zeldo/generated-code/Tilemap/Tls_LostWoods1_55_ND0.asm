	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_55
	LEAU 481,U

	LDD #$ebbe
	STD -1,U
	LDD #$1eee
	STD 79,U
	LDD #$ee4e
	STD 39,U
	LDD #$d111
	STD 119,U
	LDD #$e4b4
	STD -41,U
	LDD #$eebb
	STD -81,U
	LDB #$ee
	STD -121,U
	LEAU -280,U

	LDB #$22
	STD 119,U
	LDD #$2e11
	STD 79,U
	LDA #$12
	STD 39,U
	LDA #$11
	STD -1,U
	LDA #$21
	STD -41,U
	LDA #$22
	STD -81,U
	LDB #$21
	STD -121,U
	LEAU -201,U

	STD 40,U
	LDB #$22
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$bebe
	STD 39,U
	LDD #$eee1
	STD 79,U
	LDD #$111d
	STD 119,U
	LDD #$e44e
	STD -1,U
	LDD #$eebb
	STD -41,U
	LDB #$44
	STD -81,U
	LDB #$4b
	STD -121,U
	LEAU -280,U

	LDD #$1111
	STD -1,U
	LDB #$12
	STD -41,U
	STD -81,U
	LDD #$21e2
	STD 79,U
	LDD #$1121
	STD 39,U
	LDB #$22
	STD -121,U
	LDD #$e2be
	STD 119,U
	LEAU -201,U

	LDD #$1222
	STD 40,U
	LDA #$22
	STD ,U
	RTS

