	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_218

	stb   <glb_alphaTiles
	LEAU 441,U

	LDD #$dd33
	STD -41,U
	LDB #$3d
	STD -121,U
	LDD #$33dd
	STD 119,U
	STD 39,U
	LEAU -320,U

	LDB #$34
	STD -121,U
	LDD #$ddd3
	STD 39,U
	LDD #$33d4
	STD -41,U
	LDD #$dd3d
	STD 119,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$dd3d
	STD 119,U
	LDD #$33d4
	STD -41,U
	LDD #$ddd3
	STD 39,U
	LDD #$3334
	STD -121,U
	LEAU -320,U

	LDD #$dd43
	STD -41,U
	LDD #$3344
	STD 119,U
	STD 39,U
	LDD -121,U
	LDA #$dd
	ANDB #$0F
	ORB #$40
	STD -121,U
	RTS

