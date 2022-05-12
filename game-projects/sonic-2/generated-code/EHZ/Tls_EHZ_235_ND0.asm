	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_235

	stb   <glb_alphaTiles
	LEAU 481,U

	LDD #$877d
	STD 79,U
	STD -1,U
	LDB #$77
	STD -81,U
	LDD #$dddd
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LEAU -280,U

	LDD #$8777
	STD 119,U
	LDD #$dddd
	STD 79,U
	LDD #$7877
	STD 39,U
	STB -40,U
	LDD -1,U
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD -1,U
	STB -80,U
	LDA #$87
	STA -120,U
	LEAU -180,U

	STB 20,U
	STA -20,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$78d3
	STD 79,U
	LDB #$dd
	STD -1,U
	STD -81,U
	LDA #$dd
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LEAU -280,U

	LDD #$7877
	STD 119,U
	STD 39,U
	LDA #$88
	STD -41,U
	LDD #$dddd
	STD 79,U
	STD -1,U
	STD -81,U
	LDD -121,U
	ANDA #$F0
	ORA #$08
	LDB #$77
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
	LDB #$77
	STD -21,U
	RTS

