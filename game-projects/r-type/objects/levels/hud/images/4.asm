	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_hud_4_0
	LDA #$00
	STA 120,U
	STA 80,U
	STA 40,U
	LDA #$04
	STA ,U
	STA -40,U
	STA -80,U
	STA -120,U

	LDU <glb_screen_location_1
	LDA #$44
	STA ,U
	LDA #$04
	STA 120,U
	STA 80,U
	STA 40,U
	STA -40,U
	STA -80,U
	STA -120,U
	RTS

