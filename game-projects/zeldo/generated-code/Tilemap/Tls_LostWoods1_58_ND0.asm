	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_58
	LEAU 481,U

	LDD #$eeeb
	STD 119,U
	LDB #$e4
	STD 79,U
	STD 39,U
	LDB #$44
	STD -41,U
	LDB #$4b
	STD -81,U
	LDB #$b4
	STD -1,U
	STD -121,U
	LEAU -280,U

	LDB #$b5
	STD 119,U
	LDD #$ebee
	STD 79,U
	LDD #$b4eb
	STD -1,U
	LDA #$e5
	STD 39,U
	LDA #$b5
	STD -41,U
	LDA #$be
	STD -81,U
	LDD #$bbee
	STD -121,U
	LEAU -201,U

	LDB #$e0
	STD ,U
	LDA #$eb
	STD 40,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$be4e
	STD 119,U
	LDD #$eeee
	STD -121,U
	LDB #$5e
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	LDB #$4e
	STD 79,U
	LEAU -280,U

	LDB #$e0
	STD -41,U
	LDD #$5bbe
	STD 79,U
	LDA #$45
	STD 39,U
	LDD #$54ee
	STD -1,U
	LDD #$eebe
	STD 119,U
	LDD #$bbe1
	STD -81,U
	LDB #$01
	STD -121,U
	LEAU -201,U

	LDB #$11
	STD 40,U
	LDB #$12
	STD ,U
	RTS

