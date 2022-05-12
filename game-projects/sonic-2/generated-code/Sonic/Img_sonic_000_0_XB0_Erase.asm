	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
ERASE_Img_sonic_000_0
	STS glb_register_s

	LEAS ,U
ERASE_CODE_Img_sonic_000_0
	LEAU ,S
	LDS glb_register_s
	RTS

DataSize equ $0000
