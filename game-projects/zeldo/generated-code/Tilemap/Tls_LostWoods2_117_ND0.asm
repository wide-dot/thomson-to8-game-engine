	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_LostWoods2_117
	LEAU 481,U

	LDD #$d2e2
	STD 119,U
	LDB #$b2
	STD 79,U
	LDD #$ddbd
	STD 39,U
	LDD #$dbee
	STD -81,U
	LDB #$bb
	STD -41,U
	STD -121,U
	LDD #$deee
	STD -1,U
	LEAU -280,U

	LDA #$db
	STD 119,U
	LDB #$bb
	STD 79,U
	LDD #$ebeb
	STD -81,U
	LDB #$bb
	STD -41,U
	STD -121,U
	LDD #$eeee
	STD 39,U
	STD -1,U
	LEAU -201,U

	LDD #$dded
	STD ,U
	LDD #$debe
	STD 40,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$2e2d
	STD 79,U
	LDA #$22
	STD 119,U
	LDD #$dedd
	STD 39,U
	LDD #$eeed
	STD -1,U
	LDB #$ee
	STD -81,U
	LDD #$bbbe
	STD -41,U
	LDD #$beee
	STD -121,U
	LEAU -280,U

	LDB #$bb
	STD -121,U
	LDB #$ee
	STD 79,U
	LDD #$bbbb
	STD -41,U
	STD -81,U
	LDD #$eeee
	STD 119,U
	STD 39,U
	LDB #$eb
	STD -1,U
	LEAU -201,U

	LDD #$dedd
	STD ,U
	LDD #$eeee
	STD 40,U
	RTS

