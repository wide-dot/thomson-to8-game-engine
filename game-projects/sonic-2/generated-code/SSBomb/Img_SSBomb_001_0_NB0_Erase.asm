	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
ERASE_Img_SSBomb_001_0
	STS glb_register_s

	LEAS ,U
ERASE_CODE_Img_SSBomb_001_0
	PULS A,B,U
	STA 20,U
	STB 60,U

	PULS A,B
	STA -60,U
	STB -20,U

	PULS A,B
	STA 100,U
	STB -100,U

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

DataSize equ $000E
