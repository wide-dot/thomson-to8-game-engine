	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_230

	stb   <glb_alphaTiles
	LEAU 481,U

	LDA #$dd
	STA 120,U
	STA 40,U
	STA -40,U
	STA -120,U
	LDA #$7d
	STA 80,U
	STA ,U
	LDA #$77
	STA -80,U
	LEAU -280,U

	LDA #$87
	STA 120,U
	STA 40,U
	LDA #$dd
	STA 80,U
	STA ,U
	STA -80,U
	LDA #$78
	STA -40,U
	LDA -120,U
	ANDA #$F0
	ORA #$08
	STA -120,U
	LEAU -180,U

	LDA 20,U
	ANDA #$F0
	ORA #$0d
	STA 20,U
	LDA -20,U
	ANDA #$F0
	ORA #$08
	STA -20,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDD -41,U
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD -41,U
	LDD -81,U
	ANDA #$F0
	ORA #$08
	LDB #$dd
	STD -81,U
	LDD -121,U
	ANDA #$F0
	ORA #$0d
	LDB #$dd
	STD -121,U
	LDD #$87dd
	STD 79,U
	LDA #$78
	STD -1,U
	LDA #$dd
	STD 119,U
	STD 39,U
	LEAU -280,U

	STA 80,U
	STA ,U
	STA -80,U
	LDD 119,U
	ANDA #$F0
	ORA #$07
	LDB #$7d
	STD 119,U
	STB 40,U
	LDA #$77
	STA -40,U
	STA -120,U
	LEAU -180,U

	STA -20,U
	LDA #$dd
	STA 20,U
	RTS

