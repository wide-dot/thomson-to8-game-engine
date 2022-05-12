	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_280

	stb   <glb_alphaTiles
	LEAU 481,U

	LDA #$dd
	STA 120,U
	STA 40,U
	STA -40,U
	LDA #$33
	STA 80,U
	LDA #$43
	STA ,U
	LDD #$dddd
	STD -121,U
	LDD -81,U
	ANDA #$F0
	ORA #$0d
	LDB #$44
	STD -81,U
	LEAU -280,U

	LDD #$dddd
	STD 79,U
	STD -1,U
	STD -81,U
	LDD #$d444
	STD 119,U
	LDA #$33
	STD 39,U
	LDB #$43
	STD -41,U
	LDB #$dd
	STD -121,U
	LEAU -180,U

	LDB #$4d
	STD -21,U
	LDD #$dddd
	STD 19,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD #$d433
	STD -1,U
	LDD 79,U
	ANDA #$F0
	ORA #$0d
	LDB #$33
	STD 79,U
	LDD 39,U
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD 39,U
	STB 120,U
	LDD #$dddd
	STD -41,U
	STD -121,U
	LDD #$4434
	STD -81,U
	LEAU -280,U

	LDB #$44
	STD 119,U
	LDD #$33dd
	STD -121,U
	LDD #$4433
	STD 39,U
	LDA #$34
	STD -41,U
	LDD #$dddd
	STD 79,U
	STD -1,U
	STD -81,U
	LEAU -180,U

	LDA #$34
	STD -21,U
	LDA #$dd
	STD 19,U
	RTS

