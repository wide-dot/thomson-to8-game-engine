	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_46
	LEAU 481,U

	LDD #$1122
	STD 119,U
	LDA #$00
	STD 79,U
	LDA #$e0
	STD 39,U
	LDD #$ee12
	STD -1,U
	LDD #$be01
	STD -41,U
	LDD #$bbe0
	STD -121,U
	LDA #$4e
	STD -81,U
	LEAU -280,U

	LDD #$eebe
	STD 79,U
	LDB #$e0
	STD 119,U
	LDD #$00be
	STD 39,U
	LDB #$eb
	STD -1,U
	LDD #$100b
	STD -41,U
	LDD #$110e
	STD -81,U
	STD -121,U
	LEAU -201,U

	LDB #$00
	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$be22
	STD -81,U
	STD -121,U
	LDA #$01
	STD 39,U
	STD -1,U
	LDA #$e0
	STD -41,U
	LDA #$12
	STD 119,U
	STD 79,U
	LEAU -280,U

	LDD #$0e01
	STD 39,U
	LDD #$ee02
	STD 79,U
	LDA #$be
	STD 119,U
	LDD #$00e0
	STD -1,U
	STD -41,U
	STD -81,U
	LDA #$10
	STD -121,U
	LEAU -201,U

	LDD #$11ee
	STD ,U
	LDA #$10
	STD 40,U
	RTS

