	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_232

	stb   <glb_alphaTiles
	LEAU 481,U

	LDD #$7734
	STD 79,U
	LDD #$dddd
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LDD #$77d4
	STD -1,U
	STD -81,U
	LEAU -280,U

	LDA #$87
	STD 119,U
	LDB #$d3
	STD 39,U
	LDD #$dddd
	STD 79,U
	STD -1,U
	STD -81,U
	LDA #$88
	STD -41,U
	LDD -121,U
	ANDA #$F0
	ORA #$08
	LDB #$7d
	STD -121,U
	LEAU -180,U

	LDD 19,U
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD 19,U
	LDD -21,U
	ANDA #$F0
	ORA #$07
	LDB #$7d
	STD -21,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LDB #$44
	STD 79,U
	LDA #$7d
	STD -1,U
	STD -81,U
	LEAU -280,U

	STD 119,U
	LDD #$7733
	STD -41,U
	LDB #$3d
	STD -121,U
	LDD #$7d34
	STD 39,U
	LDD #$dddd
	STD 79,U
	STD -1,U
	STD -81,U
	LEAU -180,U

	LDA #$87
	STD -21,U
	LDA #$dd
	STD 19,U
	RTS

