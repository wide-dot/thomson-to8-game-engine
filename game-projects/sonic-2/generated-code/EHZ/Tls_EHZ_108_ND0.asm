	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_108

	stb   <glb_alphaTiles
	LEAU 481,U

	LDD 119,U
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD 119,U
	LDD 79,U
	ANDA #$F0
	ORA #$07
	LDB #$7d
	STD 79,U
	LDD 39,U
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD 39,U
	LDD #$87d3
	STD -81,U
	LDD #$dddd
	STD -41,U
	STD -121,U
	LDD #$787d
	STD -1,U
	LEAU -280,U

	LDD #$87d4
	STD 119,U
	LDA #$77
	STD 39,U
	STD -41,U
	LDD #$dddd
	STD 79,U
	STD -1,U
	STD -81,U
	LDD #$7735
	STD -121,U
	LEAU -180,U

	LDD #$dddd
	STD 19,U
	LDD #$7745
	STD -21,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$873d
	STD 79,U
	LDD #$dddd
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LDD #$773d
	STD -1,U
	LDB #$33
	STD -81,U
	LEAU -280,U

	LDD #$7d34
	STD 119,U
	LDD #$dd44
	STD -121,U
	LDA #$7d
	STD 39,U
	STD -41,U
	LDD #$dddd
	STD 79,U
	STD -1,U
	STD -81,U
	LEAU -180,U

	LDD #$d344
	STD -21,U
	LDD #$dddd
	STD 19,U
	RTS

