	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_122

	stb   <glb_alphaTiles
	LEAU 481,U

	LDD #$8787
	STD 79,U
	LDB #$88
	STD -1,U
	LDD #$dddd
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LDD #$3c88
	STD -81,U
	LEAU -280,U

	LDA #$b8
	STD 119,U
	LDD #$dddd
	STD 79,U
	STD -1,U
	STD -81,U
	LDD #$b777
	STD 39,U
	LDD #$77cb
	STD -41,U
	LDD -121,U
	ANDA #$0F
	ANDB #$F0
	ADDD #$b007
	STD -121,U
	LEAU -161,U

	LDA #$dd
	STA ,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$b7bb
	STD -81,U
	LDD #$7878
	STD 79,U
	STD -1,U
	LDD #$dddd
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LEAU -280,U

	LDD #$88cb
	STD 119,U
	LDD #$dddd
	STD 79,U
	STD -1,U
	LDD #$bb88
	STD -121,U
	LDD #$c378
	STD -41,U
	LDD -81,U
	ANDA #$0F
	ORA #$d0
	LDB #$dd
	STD -81,U
	LDD #$b387
	STD 39,U
	LEAU -181,U

	LDA #$cb
	STA -20,U
	LDD 20,U
	LDA #$dd
	ANDB #$F0
	ORB #$0d
	STD 20,U
	RTS

