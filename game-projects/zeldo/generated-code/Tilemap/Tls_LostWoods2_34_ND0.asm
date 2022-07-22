	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_34
	LEAU 481,U

	LDD #$bebb
	STD -1,U
	STD -41,U
	LDB #$b4
	STD -81,U
	LDD #$bbbb
	STD 39,U
	LDA #$4b
	STD 119,U
	STD 79,U
	LDD #$ee44
	STD -121,U
	LEAU -280,U

	LDD #$eb4b
	STD 119,U
	LDD #$bbb5
	STD 79,U
	STD 39,U
	LDB #$55
	STD -1,U
	STD -41,U
	STD -81,U
	LDA #$b4
	STD -121,U
	LEAU -201,U

	LDA #$4b
	STD ,U
	LDA #$44
	STD 40,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$bbb5
	STD -121,U
	LDD #$eb44
	STD 79,U
	LDB #$4b
	STD 39,U
	LDA #$bb
	STD -1,U
	STD -41,U
	STD -81,U
	LDD #$eeb4
	STD 119,U
	LEAU -280,U

	LDD #$4b55
	STD -1,U
	STD -41,U
	STD -81,U
	STD -121,U
	LDA #$b4
	STD 79,U
	LDA #$44
	STD 39,U
	LDD #$b445
	STD 119,U
	LEAU -201,U

	LDD #$4555
	STD ,U
	LDA #$b5
	STD 40,U
	RTS

