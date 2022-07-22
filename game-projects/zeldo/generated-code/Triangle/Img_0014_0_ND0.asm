	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_0014_0
	LEAU 3997,U

	LDA -20,U
	ANDA #$F0
	ORA #$00
	STA -20,U
	LDA #$40
	STA 20,U

	LDU <glb_screen_location_1
	LEAU 3979,U

	LDA #$04
	STA 3,U
	LDA 37,U
	ANDA #$F0
	ORA #$04
	STA 37,U
	LDA -37,U
	ANDA #$0F
	ORA #$00
	STA -37,U
	RTS

