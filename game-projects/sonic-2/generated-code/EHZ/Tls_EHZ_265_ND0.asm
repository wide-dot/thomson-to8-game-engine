	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_265

	stb   <glb_alphaTiles
	LEAU 481,U

	LDD 119,U
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD 119,U
	LDD #$34dd
	STD 79,U
	STD -1,U
	LDA #$dd
	STD 39,U
	STD -41,U
	STD -121,U
	LDD #$343d
	STD -81,U
	LEAU -240,U

	LDB #$dd
	STD 79,U
	LDA #$dd
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LDD #$4443
	STD 79,U
	LDB #$d3
	STD -1,U
	LDB #$dd
	STD -81,U
	LEAU -240,U

	LDA #$dd
	STD 79,U
	STD 39,U
	STD -1,U
	STD -41,U
	STD -81,U
	RTS

