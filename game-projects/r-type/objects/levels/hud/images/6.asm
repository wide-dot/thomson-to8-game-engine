	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_hud_6_0
	LDA #$04
	STA 120,U
	STA 80,U
	STA 40,U
	STA ,U
	STA -40,U
	STA -80,U
	LDA #$00
	STA -120,U

	LDU <glb_screen_location_1
	LDA #$44
	STA 120,U
	STA ,U
	STA -120,U
	LDA #$04
	STA 80,U
	STA 40,U
	LDA #$00
	STA -40,U
	STA -80,U
	RTS

