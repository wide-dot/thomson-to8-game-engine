	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_109

	stb   <glb_alphaTiles
	LEAU 481,U

	LDA 120,U
	ANDA #$F0
	ORA #$0d
	STA 120,U
	LDA 80,U
	ANDA #$F0
	ORA #$08
	STA 80,U
	LDA 40,U
	ANDA #$F0
	ORA #$0d
	STA 40,U
	LDA #$87
	STA -80,U
	LDA #$dd
	STA -40,U
	STA -120,U
	LDA #$78
	STA ,U
	LEAU -280,U

	LDA #$77
	STA -40,U
	LDA #$7d
	STA -120,U
	LDA #$dd
	STA 80,U
	STA ,U
	STA -80,U
	LDA #$87
	STA 120,U
	STA 40,U
	LEAU -180,U

	LDA #$7d
	STA -20,U
	LDA #$dd
	STA 20,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDA #$77
	STA 80,U
	STA ,U
	LDA #$7d
	STA -80,U
	LDA #$dd
	STA 120,U
	STA 40,U
	STA -40,U
	STA -120,U
	LEAU -280,U

	LDD #$78dd
	STD -121,U
	LDD 79,U
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD 79,U
	LDD 39,U
	ANDA #$F0
	ORA #$07
	LDB #$7d
	STD 39,U
	LDD -1,U
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD -1,U
	LDD -41,U
	ANDA #$F0
	ORA #$08
	LDB #$dd
	STD -41,U
	LDD #$dddd
	STD -81,U
	LDA #$7d
	STA 120,U
	LEAU -180,U

	LDA #$87
	STD -21,U
	LDA #$dd
	STD 19,U
	RTS

