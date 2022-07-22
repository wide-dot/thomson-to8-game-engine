	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_110
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

	STD 119,U
	LDD #$ee1e
	STD 79,U
	LDD #$ebeb
	STD 39,U
	LDB #$e4
	STD -1,U
	LDD #$b4e5
	STD -41,U
	STD -81,U
	STD -121,U
	LEAU -201,U

	LDD #$bb0b
	STD 40,U
	LDD #$eb0e
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

	STD 119,U
	LDD #$eeee
	STD 79,U
	LDD #$bebe
	STD 39,U
	LDD #$444b
	STD -1,U
	LDA #$45
	STD -41,U
	LDD #$555b
	STD -81,U
	LDA #$5b
	STD -121,U
	LEAU -201,U

	LDD #$4e4b
	STD 40,U
	LDD #$b0bb
	STD ,U
	RTS

