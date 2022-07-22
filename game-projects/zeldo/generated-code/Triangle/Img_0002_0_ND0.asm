	INCLUDE "./engine/constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
DRAW_Img_0002_0

	LDU <glb_screen_location_1
	RTS

