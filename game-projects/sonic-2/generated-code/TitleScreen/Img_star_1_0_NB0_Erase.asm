	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
ERASE_Img_star_1_0
	STS glb_register_s

	LEAS ,U
ERASE_CODE_Img_star_1_0
	PULS A,U
	STA 80,U

	PULS A
	STA -80,U

	PULS A,U
	STA 80,U

	PULS A,B
	STA ,U
	STB -80,U

	LEAU ,S
	LDS glb_register_s
	RTS

DataSize equ $0009
