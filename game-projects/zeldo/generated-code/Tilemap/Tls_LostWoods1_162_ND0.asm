	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_162
	LEAU 481,U

	LDD #$0101
	STD 119,U
	LDD #$11e0
	STD -1,U
	STD -41,U
	STD -81,U
	LDB #$01
	STD 79,U
	LDB #$00
	STD 39,U
	LDD #$10e0
	STD -121,U
	LEAU -280,U

	LDD #$eedd
	STD -1,U
	STD -41,U
	LDD #$00de
	STD 79,U
	STD 39,U
	LDB #$ee
	STD 119,U
	LDD #$dddd
	STD -81,U
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$1111
	STD 119,U
	LDA #$10
	STD 79,U
	STD 39,U
	LDA #$00
	STD -1,U
	STD -41,U
	LDD #$0e01
	STD -81,U
	STD -121,U
	LEAU -280,U

	LDB #$00
	STD 119,U
	LDA #$ee
	STD 79,U
	LDD #$ede0
	STD 39,U
	LDB #$ee
	STD -1,U
	LDD #$ddde
	STD -41,U
	LDB #$dd
	STD -81,U
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U
	RTS

