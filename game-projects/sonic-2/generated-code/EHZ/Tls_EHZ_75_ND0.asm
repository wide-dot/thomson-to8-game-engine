	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_75

	stb   <glb_alphaTiles
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LDD #$8888
	STD 79,U
	LDD #$8b78
	STD -1,U
	LDD #$88bc
	STD -81,U
	LEAU -280,U

	LDD #$bb88
	STD 119,U
	LDD #$dddd
	STD 79,U
	STD -1,U
	STD -81,U
	LDD #$cb37
	STD 39,U
	LDA #$77
	STD -41,U
	LDD #$c37b
	STD -121,U
	LEAU -160,U

	LDD -1,U
	ANDA #$0F
	ANDB #$0F
	ADDD #$d0d0
	STD -1,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$dddd
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LDD #$cb78
	STD -1,U
	LDA #$78
	STD 79,U
	LDD #$7738
	STD -81,U
	LEAU -280,U

	LDD #$dddd
	STD 79,U
	STD -1,U
	STD -81,U
	LDD #$7778
	STD 119,U
	LDD #$7bbb
	STD 39,U
	LDD #$7c77
	STD -41,U
	LDD -121,U
	ANDA #$F0
	ORA #$07
	LDB #$cb
	STD -121,U
	LEAU -180,U

	LDD -21,U
	ANDA #$0F
	ANDB #$F0
	ADDD #$7007
	STD -21,U
	LDD 19,U
	ANDA #$0F
	ORA #$d0
	LDB #$dd
	STD 19,U
	RTS

