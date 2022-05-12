	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_112

	stb   <glb_alphaTiles
	LEAU 561,U

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

	LDU <glb_screen_location_1
	LEAU 481,U

	LDA #$dd
	STA 120,U
	STA 40,U
	STA -40,U
	STA -120,U
	LDA #$87
	STA 80,U
	STA ,U
	STA -80,U
	LEAU -280,U

	LDA #$77
	STA 120,U
	STA 40,U
	LDA #$dd
	STA 80,U
	LDA ,U
	ANDA #$F0
	ORA #$0d
	STA ,U
	LDA -40,U
	ANDA #$F0
	ORA #$07
	STA -40,U
	LDA -80,U
	ANDA #$F0
	ORA #$0d
	STA -80,U
	LDA -120,U
	ANDA #$F0
	ORA #$07
	STA -120,U
	LEAU -180,U

	LDA 20,U
	ANDA #$F0
	ORA #$0d
	STA 20,U
	LDA -20,U
	ANDA #$F0
	ORA #$07
	STA -20,U
	RTS

