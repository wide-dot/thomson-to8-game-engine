	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods1_182
	LEAU 481,U

	LDD #$1eeb
	STD 39,U
	LDB #$ee
	STD -1,U
	LDB #$bb
	STD 79,U
	LDD #$0ebe
	STD 119,U
	LDD #$d044
	STD -41,U
	LDD #$d1be
	STD -81,U
	LDD #$dde1
	STD -121,U
	LEAU -280,U

	LDB #$11
	STD 119,U
	LDD #$eddd
	STD 79,U
	LDA #$b0
	STD 39,U
	LDA #$4e
	STD -1,U
	LDD #$4bbb
	STD -121,U
	LDD #$ebee
	STD -81,U
	LDD #$bb1d
	STD -41,U
	LEAU -201,U

	LDD #$4eb4
	STD 40,U
	LDA #$eb
	STD ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$4beb
	STD 119,U
	LDD #$eeb4
	STD 79,U
	LDA #$44
	STD 39,U
	LDD #$1eeb
	STD -121,U
	LDD #$e4e4
	STD -41,U
	LDD #$0bbe
	STD -81,U
	LDD #$b4b4
	STD -1,U
	LEAU -280,U

	LDD #$d2ee
	STD 119,U
	LDD #$dddd
	STD 79,U
	LDA #$1d
	STD 39,U
	LDA #$01
	STD -1,U
	LDA #$e0
	STD -41,U
	LDA #$ee
	STD -81,U
	LDB #$ed
	STD -121,U
	LEAU -201,U

	LDA #$be
	STD 40,U
	STD ,U
	RTS

