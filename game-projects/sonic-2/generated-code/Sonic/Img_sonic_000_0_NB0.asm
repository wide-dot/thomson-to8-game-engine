	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
BCKDRAW_Img_sonic_000_0
	STS glb_register_s

	LEAS ,Y

	LDU <glb_screen_location_1
	LEAU ,S
SSAV_Img_sonic_000_0
	LDS glb_register_s
	RTS

