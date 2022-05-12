	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
ERASE_Img_SSBomb_002_0
	STS glb_register_s

	LEAS ,U
ERASE_CODE_Img_SSBomb_002_0
	PULS A,U
	STA ,U

	PULS A,B,U
	STA -40,U
	STB -120,U

	PULS A,B
	STA 40,U
	STB 120,U

	PULS A,B
	STA ,U
	STB -80,U

	PULS A
	STA 80,U

	PULS A,U
	STA ,U

	PULS A,U
	STA -120,U

	PULS A,B
	STA 120,U
	STB -80,U

	PULS A,B
	STA ,U
	STB 40,U

	PULS A,B
	STA -40,U
	STB 80,U

	LEAU ,S
	LDS glb_register_s
	RTS

DataSize equ $0018
