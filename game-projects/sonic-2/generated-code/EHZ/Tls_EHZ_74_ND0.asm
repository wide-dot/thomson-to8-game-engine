	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_74

	stb   <glb_alphaTiles
	LEAU 481,U

	LDD #$8777
	STD 79,U
	LDD #$dddd
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LDD #$8788
	STD -1,U
	LDD #$8b83
	STD -81,U
	LEAU -280,U

	LDD -121,U
	LDA #$77
	ANDB #$F0
	ORB #$0b
	STD -121,U
	LDD #$dddd
	STD 79,U
	STD -1,U
	STD -81,U
	LDD #$788b
	STD 39,U
	LDB #$bc
	STD -41,U
	LDD #$8c88
	STD 119,U
	LEAU -180,U

	LDA -20,U
	ANDA #$F0
	ORA #$0c
	STA -20,U
	LDA #$dd
	STA 20,U

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
	LDD #$b8cb
	STD -81,U
	LEAU -280,U

	LDB #$78
	STD 119,U
	LDD #$dddd
	STD 79,U
	STD -1,U
	LDD #$3c37
	STD -41,U
	LDA #$77
	STD 39,U
	LDD -81,U
	ANDA #$F0
	ANDB #$0F
	ADDD #$0dd0
	STD -81,U
	LDA #$b3
	STA -120,U
	LEAU -180,U

	LDD -21,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$80b0
	STD -21,U
	LDD 19,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD 19,U
	RTS

