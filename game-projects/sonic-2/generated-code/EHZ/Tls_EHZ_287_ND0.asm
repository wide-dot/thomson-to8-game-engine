	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Tls_EHZ_287

	stb   <glb_alphaTiles
	LEAU 500,U

	LDA #$dd
	STA 100,U
	STA 20,U
	LDA #$33
	STA 60,U
	STA -20,U
	LDA -60,U
	ANDA #$0F
	ORA #$d0
	STA -60,U
	LDA -100,U
	ANDA #$0F
	ORA #$40
	STA -100,U

	LDU <glb_screen_location_1
	LEAU 580,U

	LDA 20,U
	ANDA #$0F
	ORA #$d0
	STA 20,U
	LDA -20,U
	ANDA #$0F
	ORA #$30
	STA -20,U
	RTS

