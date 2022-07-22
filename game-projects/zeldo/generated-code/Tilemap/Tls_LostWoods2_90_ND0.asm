	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_90
	LEAU 481,U

	LDD #$eddd
	STD 119,U
	LDD #$b011
	STD 79,U
	LDD #$5e00
	STD 39,U
	LDD #$bee0
	STD -1,U
	LDB #$b5
	STD -121,U
	LDD #$5bbb
	STD -41,U
	LDB #$b5
	STD -81,U
	LEAU -280,U

	LDA #$eb
	STD 119,U
	LDD #$bb5b
	STD 79,U
	LDB #$5e
	STD 39,U
	LDA #$5b
	STD -1,U
	LDD #$55be
	STD -41,U
	LDD #$b5eb
	STD -81,U
	LDD #$5bbb
	STD -121,U
	LEAU -201,U

	LDD #$b55e
	STD ,U
	LDD #$5bbe
	STD 40,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	STD 79,U
	LDD #$110d
	STD 39,U
	LDD #$00bd
	STD -1,U
	LDD #$eb5d
	STD -121,U
	LDA #$ee
	STD -81,U
	LDA #$00
	STD -41,U
	LEAU -280,U

	LDD #$ebed
	STD 119,U
	LDD #$bb1d
	STD -41,U
	LDB #$dd
	STD 39,U
	LDD #$be1d
	STD -1,U
	LDD #$eb0d
	STD 79,U
	LDD #$bb01
	STD -81,U
	LDD #$55e1
	STD -121,U
	LEAU -201,U

	LDD #$bbbb
	STD ,U
	LDD #$b5be
	STD 40,U
	RTS

