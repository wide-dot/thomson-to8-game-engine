	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_376

	stb   <glb_alphaTiles
	LEAU 480,U

	LDA #$dd
	STA 120,U
	STA 40,U
	STA -40,U
	LDA #$33
	STA 80,U
	LDA -80,U
	ANDA #$0F
	ORA #$40
	STA -80,U
	LDA -120,U
	ANDA #$0F
	ORA #$d0
	STA -120,U
	LDA #$54
	STA ,U

	LDU <glb_screen_location_1
	LEAU 540,U

	LDA #$33
	STA 20,U
	LDA #$dd
	STA 60,U
	LDA -20,U
	ANDA #$0F
	ORA #$d0
	STA -20,U
	LDA -60,U
	ANDA #$0F
	ORA #$30
	STA -60,U
	RTS

