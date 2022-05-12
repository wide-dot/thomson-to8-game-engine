	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_275

	stb   <glb_alphaTiles
	LEAU 481,U

	LDD #$dddd
	STD 39,U
	STD -41,U
	LDB #$d4
	STD -81,U
	LDB #$dd
	STD -121,U
	LDD 119,U
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD 119,U
	LDD 79,U
	ANDA #$F0
	ORA #$0d
	LDB #$44
	STD 79,U
	LDD #$dd44
	STD -1,U
	LEAU -280,U

	LDD #$4d34
	STD -121,U
	LDD #$4344
	STD 39,U
	LDA #$44
	STD -41,U
	LDD #$ddd3
	STD 119,U
	LDB #$dd
	STD 79,U
	STD -1,U
	STD -81,U
	LEAU -180,U

	STD 19,U
	STD -21,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$d344
	STD 79,U
	LDD #$dddd
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LDD #$3d44
	STD -1,U
	LDD #$dd4d
	STD -81,U
	LEAU -280,U

	LDB #$dd
	STD 79,U
	STD -1,U
	STD -81,U
	LDB #$3d
	STD 119,U
	LDB #$43
	STD 39,U
	STD -121,U
	LDD #$3444
	STD -41,U
	LEAU -180,U

	LDD #$dddd
	STD 19,U
	STD -21,U
	RTS

