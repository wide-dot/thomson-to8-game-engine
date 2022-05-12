	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
ERASE_Img_SSRing_003_0
	STS glb_register_s

	LEAS ,U
ERASE_CODE_Img_SSRing_003_0
	PULS A,B,U
	STA -20,U
	STB 20,U

	PULS A,B,U
	STA -20,U
	STB 20,U

	PULS A,U
	STA 120,U

	PULS A,X,Y
	STA -120,U
	STX 79,U
	STY 39,U

	PULS D,X,Y
	STD -1,U
	STX -41,U
	STY -81,U

	LEAU ,S
	LDS glb_register_s
	RTS

DataSize equ $0016
