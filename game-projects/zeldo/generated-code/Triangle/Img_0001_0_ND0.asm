	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_0001_0
	LEAU 4018,U

	LDA ,U
	ANDA #$0F
	ORA #$30
	STA ,U

	LDU <glb_screen_location_1
	LEAU 3999,U

	LDA #$33
	STA -18,U
	LDA 18,U
	ANDA #$F0
	ORA #$03
	STA 18,U
	RTS

