	INCLUDE "./Engine/Constants.asm"
	ORG $A000
	SETDP $FF
	OPT C,CT
ERASE_Img_SSShadow_018_0
	STS glb_register_s

	LEAS ,U
ERASE_CODE_Img_SSShadow_018_0
	PULS A,B,U
	STA 40,U
	STB 80,U

	PULS D
	STD ,U

	PULS A,B
	STA -80,U
	STB -40,U

	PULS D,U
	STD 39,U

	PULS D,X
	STD -1,U
	STX -41,U

	PULS A,B
	STA 80,U
	STB -80,U

	LEAU ,S
	LDS glb_register_s
	RTS

DataSize equ $0012
