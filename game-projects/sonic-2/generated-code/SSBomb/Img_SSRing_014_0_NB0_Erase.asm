	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
ERASE_Img_SSRing_014_0
	STS glb_register_s

	LEAS ,U
ERASE_CODE_Img_SSRing_014_0
	PULS A,B,U
	STA -20,U
	STB 20,U

	PULS A,B
	STA 60,U
	STB -60,U

	PULS A,U
	STA 60,U

	PULS A,B
	STA 20,U
	STB -20,U

	PULS A
	STA -60,U

	PULS A,B,U
	STA ,U
	STB 40,U

	PULS D
	STD -41,U

	PULS A,B,U
	STA -80,U
	STB -120,U

	PULS D,X,Y
	STD 119,U
	STX 79,U
	STY 39,U

	PULS D,X
	STD -1,U
	STX -41,U

	LEAU ,S
	LDS glb_register_s
	RTS

DataSize equ $0020