	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_188
	LEAU 481,U

	LDD #$0ddd
	STD 39,U
	STD -1,U
	LDA #$1d
	STD 119,U
	STD 79,U
	LDA #$01
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -280,U

	LDA #$44
	STD -1,U
	STD -41,U
	STD -81,U
	LDA #$ee
	STD 79,U
	LDA #$bb
	STD 39,U
	LDA #$e1
	STD 119,U
	LDA #$5e
	STD -121,U
	LEAU -201,U

	LDA #$41
	STD 40,U
	LDA #$e1
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -280,U

	LDA #$ed
	STD -1,U
	STD -41,U
	LDA #$0d
	STD 39,U
	LDA #$dd
	STD 119,U
	STD 79,U
	STD -81,U
	STD -121,U
	LEAU -201,U

	STD 40,U
	STD ,U
	RTS

