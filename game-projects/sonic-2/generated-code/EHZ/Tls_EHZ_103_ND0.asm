	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_103

	stb   <glb_alphaTiles
	LEAU 481,U

	LDA #$dd
	STA 120,U
	STA 40,U
	STA -40,U
	LDD #$dddd
	STD -121,U
	LDA #$77
	STA ,U
	LDD -81,U
	ANDA #$F0
	ORA #$08
	LDB #$77
	STD -81,U
	LDA #$87
	STA 80,U
	LEAU -280,U

	LDA #$88
	STD 119,U
	LDD #$dddd
	STD 79,U
	STD -1,U
	STD -81,U
	LDD #$8777
	STD 39,U
	STD -41,U
	LDB #$7d
	STD -121,U
	LEAU -180,U

	LDD #$dddd
	STD 19,U
	LDD #$87d3
	STD -21,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$dddd
	STD -41,U
	STD -121,U
	LDD #$8877
	STD -1,U
	STD -81,U
	LDD 119,U
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD 119,U
	LDD 79,U
	ANDA #$F0
	ORA #$08
	LDB #$77
	STD 79,U
	LDD 39,U
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD 39,U
	LEAU -280,U

	LDD #$7877
	STD 119,U
	LDD #$dddd
	STD 79,U
	STD -1,U
	STD -81,U
	LDD #$78d7
	STD 39,U
	LDB #$dd
	STD -41,U
	STD -121,U
	LEAU -180,U

	LDA #$dd
	STD 19,U
	LDD #$7833
	STD -21,U
	RTS

