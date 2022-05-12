	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_240

	stb   <glb_alphaTiles
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LDD #$8787
	STD 79,U
	STD -1,U
	STD -81,U
	LEAU -280,U

	LDA #$78
	STD -121,U
	LDD #$dddd
	STD 79,U
	STD -1,U
	STD -81,U
	LDD #$8887
	STD -41,U
	LDA #$87
	STD 119,U
	STD 39,U
	LEAU -180,U

	STA -20,U
	LDD 19,U
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD 19,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LDD #$7878
	STD 79,U
	STD -1,U
	STD -81,U
	LEAU -280,U

	LDD #$dddd
	STD 79,U
	STD -1,U
	STD -81,U
	LDD #$7878
	STD 119,U
	STD 39,U
	STD -41,U
	LDA #$88
	STD -121,U
	LEAU -180,U

	STD -21,U
	LDD #$dddd
	STD 19,U
	RTS

