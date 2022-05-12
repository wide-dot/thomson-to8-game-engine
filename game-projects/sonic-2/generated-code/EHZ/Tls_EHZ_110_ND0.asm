	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_110

	stb   <glb_alphaTiles
	LEAU 41,U

	LDA 40,U
	ANDA #$F0
	ORA #$07
	STA 40,U
	LDA ,U
	ANDA #$F0
	ORA #$0d
	STA ,U
	LDA -40,U
	ANDA #$F0
	ORA #$08
	STA -40,U

	LDU <glb_screen_location_1
	LEAU 481,U

	LDA 120,U
	ANDA #$F0
	ORA #$0d
	STA 120,U
	LDA 80,U
	ANDA #$F0
	ORA #$07
	STA 80,U
	LDA 40,U
	ANDA #$F0
	ORA #$0d
	STA 40,U
	LDA ,U
	ANDA #$F0
	ORA #$07
	STA ,U
	LDA -40,U
	ANDA #$F0
	ORA #$0d
	STA -40,U
	LDA -80,U
	ANDA #$F0
	ORA #$07
	STA -80,U
	LDA #$dd
	STA -120,U
	LEAU -280,U

	LDA #$87
	STA 40,U
	STA -40,U
	STA -120,U
	LDA #$dd
	STA 80,U
	STA ,U
	STA -80,U
	LDA #$77
	STA 120,U
	LEAU -180,U

	STA -20,U
	LDA #$dd
	STA 20,U
	RTS

