	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_166

	stb   <glb_alphaTiles
	LEAU 481,U

	LDD #$8787
	STD 79,U
	STD -1,U
	STD -81,U
	LDD #$dddd
	STD 119,U
	STD 39,U
	STD -41,U
	STD -121,U
	LEAU -280,U

	STD 79,U
	LDD #$8787
	STD 119,U
	STD 39,U
	LDD -1,U
	ANDA #$0F
	ORA #$d0
	LDB #$dd
	STD -1,U
	LDD -121,U
	ANDA #$0F
	ORA #$80
	LDB #$54
	STD -121,U
	LDA #$84
	STA -40,U
	LDA #$dd
	STA -80,U
	LEAU -180,U

	LDD 19,U
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD 19,U
	LDD -21,U
	ANDA #$F0
	ORA #$07
	LDB #$44
	STD -21,U

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
	LEAU -281,U

	STD 120,U
	LDD ,U
	LDA #$dd
	ANDB #$0F
	ORB #$d0
	STD ,U
	LDD #$7478
	STD 40,U
	LDD #$dddd
	STD 80,U
	LDA #$74
	STA -40,U
	LDA -80,U
	ANDA #$F0
	ORA #$0d
	STA -80,U
	LDA -120,U
	ANDA #$F0
	ORA #$04
	STA -120,U
	LEAU -180,U

	STB 20,U
	LDA #$34
	STA -20,U
	RTS

