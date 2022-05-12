	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_255

	stb   <glb_alphaTiles
	LEAU 441,U

	LDD #$3333
	STD 119,U
	LDD #$3443
	STD 39,U
	LDD -121,U
	ANDA #$F0
	ORA #$03
	LDB #$43
	STD -121,U
	LDD #$d344
	STD -41,U
	LEAU -320,U

	LDA #$dd
	STA 120,U
	STA 40,U
	STA -40,U
	LDA -120,U
	ANDA #$F0
	ORA #$0d
	STA -120,U

	LDU <glb_screen_location_1
	LEAU 441,U

	LDD #$4444
	STD -41,U
	LDB #$33
	STD 119,U
	LDB #$34
	STD 39,U
	LDA #$34
	STD -121,U
	LEAU -320,U

	LDA #$d4
	STA -40,U
	STA -120,U
	LDD 39,U
	ANDA #$F0
	ORA #$03
	LDB #$dd
	STD 39,U
	LDD #$33dd
	STD 119,U
	RTS

