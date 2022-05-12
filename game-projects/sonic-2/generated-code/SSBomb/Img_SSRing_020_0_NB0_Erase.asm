	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
ERASE_Img_SSRing_020_0
	STS glb_register_s

	LEAS ,U
ERASE_CODE_Img_SSRing_020_0
	PULS A,U
	STA 60,U

	PULS A,B
	STA 20,U
	STB -20,U

	PULS A
	STA -60,U

	LEAU ,S
	LDS glb_register_s
	RTS

DataSize equ $0006
