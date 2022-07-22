	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_131
	LEAU 481,U

	LDD #$b4e1
	STD 119,U
	STD 79,U
	STD 39,U
	LDA #$bb
	STD -1,U
	LDB #$e0
	STD -41,U
	LDB #$b0
	STD -81,U
	LDB #$be
	STD -121,U
	LEAU -280,U

	STD 119,U
	LDD #$b4ee
	STD -121,U
	LDD #$eeeb
	STD -41,U
	LDA #$55
	STD -81,U
	LDD #$bbee
	STD 79,U
	STD 39,U
	LDB #$eb
	STD -1,U
	LEAU -201,U

	LDD #$ee44
	STD ,U
	LDB #$e4
	STD 40,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$bb12
	STD 119,U
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	LDB #$11
	STD -81,U
	STD -121,U
	LEAU -280,U

	STD 119,U
	LDB #$01
	STD 79,U
	LDB #$e0
	STD 39,U
	LDB #$ee
	STD -1,U
	LDA #$eb
	STD -41,U
	LDD #$5ebe
	STD -81,U
	LDA #$45
	STD -121,U
	LEAU -201,U

	LDD #$eeee
	STD ,U
	LDD #$b4be
	STD 40,U
	RTS

